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
psql -d $DB -c "DELETE FROM mrs_qb_asmt_data_sort_temp WHERE date < now() - interval '7 days';"
psql -d $DB -c "CLUSTER mrs_qb_asmt_data_sort_temp USING mrs_qb_asmt_data_sort_temp_session_id_ndx;"
echo 'finished';

