#!/bin/sh

# Feb 26, 2014 DLANDIS - the purpose of this cron is to check the DB error logs for error messages
# that are generated when a browser times out due to node not responding.  This will then email
# the ADMINS so that the ADMINS can then fix the problem :)

cd /coins/db_crons/DxMonitor/checkErrorLog
TODAY=`date`
HOSTNAME=`hostname`
DB="coins"
FROM="coins-notifier@mrn.org"
MAIL_DIR="/tmp/login_permissions_msg.txt"
echo $TODAY 
echo ""

# set this to where you want results mailed
ADMINS=`cat /coins/db_crons/admin_emails`
#ADMINS=dlandis@mrn.org

FOO_FILE="foo.txt"

# -d   d:defines database name
# -o   o:outputs response to file specified
# -tAc t:turns of printing columns/headers 
#      A:switches to unaligned output mode 
#      c:specifies to execute following command

#FUNCTIONS
psql -d $DB -o $FOO_FILE -tAc "
   SELECT *, error_timestamp + '06:58:27' AS approximate_portal_log_time
   FROM mrs_client_error_log 
   WHERE error_timestamp > now() - interval '5 minutes' 
   AND error_message LIKE ('%_jqjsp%');
"

# do the comparison
if [ ! -s $FOO_FILE ]

then
   echo Same
else
   MAIL_IT=Y
   echo Different
fi

chmod 755 $FOO_FILE

SUBJECT="ERROR: DX may not be running in the browser anymore and may need to be restarted! $HOSTNAME $DB"
if test "$MAIL_IT" = "Y"
then
    echo "To: "$ADMINS > $MAIL_DIR
    echo "From: "$FROM >> $MAIL_DIR
    echo "Subject: "$SUBJECT >> $MAIL_DIR
    echo "" >> $MAIL_DIR
    echo "" >> $MAIL_DIR
    cat $FOO_FILE >> $MAIL_DIR
    ssmtp $ADMINS < $MAIL_DIR
fi

echo ""
TODAY=`date`
echo $TODAY

exit

