#!/bin/sh
cd /coins/db_crons/permissions/sec_definers
TODAY=`date`
HOSTNAME=`hostname`;
TEMP_DIR="tmp.txt"
DB="coins"
FROM="coins-notifier@mrn.org"
MAIL_DIR="/tmp/security_definer_msg.txt"

echo "this script is run by user postgres on $HOSTNAME as a cronjob"
echo "db_crons/permissions/sec_definers/definer_driver.sh"
echo ""

# set this to where you want results mailed
ADMINS=`cat /coins/db_crons/admin_emails`
#ADMINS=dwood@mrn.org

# cp PREVIOUS final.txt file to permissions directory for comparison purposes
cd finals
cp -r `ls --sort=time|head -1` ../prev_final.driver.txt
cd ../

# run the test 
sh test_definers.sh >$TEMP_DIR 2>&1

# cp NEW final.txt file to permissions directory for comparison purposes
cd finals
cp -r `ls --sort=time|head -1` ../new_final.driver.txt
cd ../

# do the comparison
if diff prev_final.driver.txt new_final.driver.txt >/dev/null 
then
	echo Same
else
  	MAIL_IT=Y
	d=`date +%Y%m%d%H%M%S`
	f="changes/changes_${d}.txt"
	a="tmp.txt"
	cp $a $f
	echo Different
fi

chmod 755 $TEMP_DIR

SUBJECT="Number of Functions/Security Definers Changed on $HOSTNAME $DB - "${TODAY}
if test "$MAIL_IT" = "Y"
then
    echo "To: "$ADMINS > $MAIL_DIR
    echo "From: "$FROM >> $MAIL_DIR
    echo "Subject: "$SUBJECT >> $MAIL_DIR
    echo "" >> $MAIL_DIR
    echo "" >> $MAIL_DIR
    cat $TEMP_DIR >> $MAIL_DIR
    ssmtp $ADMINS < $MAIL_DIR
fi

rm tmp.txt prev_final.driver.txt new_final.driver.txt

exit


