#!/bin/bash

# Author: Dylan Wood
# Date: May.15.2015
# Script is called from /etc/cron.daily/pg_restore_coins_db_driver.sh.

echo 'Starting COINS DB refresh as user:'
echo `id`
echo `date`

# Define variables
ARCHIVE_DIR="/coins/mnt/ni/prd-backups/hid/mrsdba/prd"
ARCHIVE_FILE=`ls -1t $ARCHIVE_DIR | head -1`
DBNAME="coins"

# Drop coins database

# First, disconnect all connections
echo 'Terminating connections to DB'
psql -d $DBNAME -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND datname = '$DBNAME';"

# Drop DB
echo 'Dropping DB'
dropdb $DBNAME

# Create empty DB
echo 'Creating empty DB'
createdb $DBNAME

# Restore DB
echo 'Restoring DB from archive'
pg_restore -d $DBNAME $ARCHIVE_DIR/$ARCHIVE_FILE

# Edit default search path
echo 'Setting default search path'
psql -d $DBNAME -c 'ALTER DATABASE nirep SET search_path=mrsdba, casdba, public;'

echo 'Finished with COINS DB refresh'
echo `date`
