# DB_CRONS

A collection of scripts and programs that maintain the COINS database. These scripts and programs are called periodically from a cron.

Note: installing this repo does not set up any crons. Cron jobs should be set up for each individual script that needs to be run on a given sever.

The easiest way to set up these crons is to copy the coins.cron file to `/etc/cron.d/.`. Ensure that the postgres user has ample permissions to execute all scripts.

