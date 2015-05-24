#!/bin/sh

# Oct, 31 2013 DLANDIS - this file set up to run the SQL function casdba.cas_update_coins_metrics_table_f()

TODAY=`date`
HOSTNAME=`hostname`
DB="coins"
echo $TODAY 
echo ""

# -d   d:defines database name
# -c   c:specifies to execute following command

psql -d $DB -c "SELECT casdba.cas_update_coins_metrics_table_f();"

echo 'finished';
