#!/bin/bash

# Author: Dylan Wood
# Date: May.15.2015
# Script to be run daily (put in /etc/cron.daily/) to restore the coins db on this server from the latest backup.

# Switch to the pg user:
PG_SERVICE_USER=postgres
SCRIPT_PATH=/coins/db_crons/rep_restore/pg_restore_coins_db.sh
sudo -u $PG_SERVICE_USER $SCRIPT_PATH
