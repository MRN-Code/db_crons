#!/bin/bash

# May 20 2015, DWOOD
# Called monthly from /etc/cron.d/coinsTableTrim

TODAY=`date`
HOSTNAME=`hostname`;
DB="coins"
echo $TODAY 
echo ""
# -d   d:defines database name
# -c   c:specifies to execute following command
echo "DB: $DB // $HOSTNAME"
psql -d $DB -c "DELETE FROM mrs_client_error_log WHERE error_timestamp < now() - interval '30 days';"
psql -d $DB -c "CLUSTER mrs_client_error_log USING mrs_client_error_log_error_timestamp_ndx;"
echo 'finished';

