#!/bin/sh

# Oct, 31 2013 DLANDIS - this file set up to run the SQL function casdba.cas_update_coins_metrics_table_f()

TODAY=`date`
HOSTNAME=`hostname`;
echo $TODAY 
echo ""

# Set DB based on which server the file is located
if test $HOSTNAME = "nirepdb.mind.unm.edu"
then
	DB="devdb"
        PORT="-p 5432"
else
	DB="postgres"
        PORT="-p 6117"
fi

# -d   d:defines database name
# -c   c:specifies to execute following command

psql $PORT -d $DB -c "SELECT casdba.cas_update_coins_metrics_table_f();"

echo 'finished';
