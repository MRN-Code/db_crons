#!/bin/bash

# May 24 2015, DWOOD
# Called monthly from /etc/cron.d/coinsTableTrim

TODAY=`date`
HOSTNAME=`hostname`;
DB="coins"
echo $TODAY 
echo ""

# -d   d:defines database name
# -c   c:specifies to execute following command
echo "DB: $DB // $HOSTNAME"
psql -d $DB -c "DELETE FROM mrs_assessment_responses_hist WHERE mod_date < now() - interval '90 days';"
psql -d $DB -c "VACUUM mrs_assessment_responses_hist;"

echo 'finished';

