#!/bin/bash

# Author: Dylan Wood
# Date: June.20.2015
# Script is called from /etc/cron.d/coins_query_restore

echo 'Starting COINS DB refresh as user:'
echo `id`
echo `date`

# Define variables
ARCHIVE_DIR="/export/ni/prodrepdbcoin.sql"
ARCHIVE_FILE=`ls -1t $ARCHIVE_DIR | head -1`
DBNAME="postgres"
DBPORT=6117

# Create temp database
# Create empty DB
echo 'Creating empty DB'
createdb -p $DBPORT ${DBNAME}_temp

# Create lang
echo 'create plpgsql lang'
psql -p $DBPORT -d ${DBNAME}_temp -c 'CREATE LANGUAGE plpgsql'

# Restore DB
echo 'restoring db from latest dump'
psql -p $DBPORT -d ${DBNAME}_temp -f $ARCHIVE_FILE

# Edit default search path
echo 'Setting default search path'
psql -p $DBPORT -d ${DBNAME}_temp -c "ALTER DATABASE ${DBNAME}_temp SET search_path=mrsdba, casdba, public;"

# Truncate qb temp tables
echo 'Truncating QB temp tables'
psql -p $DBPORT -d ${DBNAME}_temp -c "TRUNCATE TABLE mrsdba.mrs_qb_asmt_data_sort_temp; TRUNCATE TABLE mrsdba.mrs_qb_asmt_pivot_categories_temp;"

# Add empty schemas
echo 'Adding casdba, dxdba and dtdba'
psql -p $DBPORT -d ${DBNAME}_temp -c "CREATE schema casdba; CREATE schema dxdba; CREATE schema dtdba;"

# Create tablefunc extension
echo 'Create tablefunc extension'
psql -p $DBPORT -d ${DBNAME}_temp -f /usr/share/pgsql/contrib/tablefunc.sql

# VACUUM ANALYZE THE DB
echo 'VACUUM ANALYZE'
psql -p $DBPORT -d ${DBNAME}_temp -c "VACUUM ANALYZE"

# Drop database

# First, disconnect all connections
echo 'Terminating connections to DB'
psql -d $DBNAME -p $DBPORT -c "SELECT pg_terminate_backend(procpid) FROM pg_stat_activity WHERE procpid <> pg_backend_pid() AND datname = '$DBNAME';"

# Drop DB
echo 'Dropping DB'
dropdb -p $DBPORT $DBNAME

# Rename temp DB
echo 'Renaming temp database'
psql -d habaridb -p $DBPORT -c "ALTER DATABASE ${DBNAME}_temp RENAME TO ${DBNAME};"

echo 'Finished with COINS DB refresh'
echo `date`
