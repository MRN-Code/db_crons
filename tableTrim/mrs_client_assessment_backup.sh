#!/bin/bash

# Aug, 11 2014 CDIERINGER - clear old records from client assessment backup
# May, 24 2015 DWOOD- update for COINS3.0 DB name and ports

TODAY=`date`
HOSTNAME=`hostname`;
DB="coins"
echo $TODAY 
echo ""

# -d   d:defines database name
# -c   c:specifies to execute following command
echo "DB: $DB // $HOSTNAME"
psql -d $DB -c "DELETE FROM mrs_client_assessment_backups WHERE device_id NOT IN ( select distinct device_id from mrs_client_assessment_backups_hist where mod_date > now() - interval '21 days' ); DELETE FROM mrs_client_assessment_backups_hist WHERE device_id NOT IN ( select distinct device_id from mrs_client_assessment_backups_hist where mod_date > now() - interval '21 days' );"

echo 'finished';
