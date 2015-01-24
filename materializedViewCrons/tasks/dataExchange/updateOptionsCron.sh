#!/bin/sh

# June, 20 2013 DLANDIS - this file set up to run the SQL function dxdba.dx_update_options_f()

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

psql $PORT -d $DB -c "SELECT dxdba.dx_update_options_f();"

psql $PORT -d $DB -c "VACUUM ANALYZE dxdba.dx_options_mv;"
psql $PORT -d $DB -c "VACUUM ANALYZE dxdba.dx_series_mv;"
psql $PORT -d $DB -c "VACUUM ANALYZE dxdba.dx_asmts_mv;"
psql $PORT -d $DB -c "VACUUM ANALYZE dxdba.dx_studies_mv;"
psql $PORT -d $DB -c "VACUUM ANALYZE dxdba.dx_subjects_mv;"

echo 'finished';
