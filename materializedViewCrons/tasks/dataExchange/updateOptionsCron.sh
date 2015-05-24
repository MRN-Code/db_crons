#!/bin/sh

# June, 20 2013 DLANDIS - this file set up to run the SQL function dxdba.dx_update_options_f()

TODAY=`date`
HOSTNAME=`hostname`
DB="coins"
echo $TODAY 
echo ""

# -d   d:defines database name
# -c   c:specifies to execute following command

psql -d $DB -c "SELECT dxdba.dx_update_options_f();"

psql -d $DB -c "VACUUM ANALYZE dxdba.dx_options_mv;"
psql -d $DB -c "VACUUM ANALYZE dxdba.dx_series_mv;"
psql -d $DB -c "VACUUM ANALYZE dxdba.dx_asmts_mv;"
psql -d $DB -c "VACUUM ANALYZE dxdba.dx_studies_mv;"
psql -d $DB -c "VACUUM ANALYZE dxdba.dx_subjects_mv;"

echo 'finished';
