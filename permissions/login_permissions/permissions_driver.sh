#!/bin/sh
cd /coins/db_crons/permissions/login_permissions
TODAY=`date`
HOSTNAME=`hostname`;
TEMP_DIR="tmp.txt"
DB="coins"

echo "this script is run by user postgres on $HOSTNAME as a cronjob"
echo "/coins/db_crons/permissions/login_permissions/permissions_driver.sh"
echo ""

# set this to where you want results mailed
ADMINS=dlandis@mrn.org,dwood@mrn.org,rwang@mrn.org,rkelly@mrn.org,cdieringer@mrn.org
#ADMINS=dlandis@mrn.org

# cp PREVIOUS final.txt file to permissions directory for comparison purposes
cd finals
cp -r `ls --sort=time|head -1` ../prev_final.driver.txt
cd ../

# run the test 
sh test_permissions.sh >$TEMP_DIR 2>&1

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

SUBJECT="Permissions Changed on $HOSTNAME $DB - "${TODAY}
if test "$MAIL_IT" = "Y"
then
	/bin/mail -s "$SUBJECT" $ADMINS <$TEMP_DIR
fi

rm tmp.txt prev_final.driver.txt new_final.driver.txt

exit

