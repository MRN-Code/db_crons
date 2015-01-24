#!/bin/sh

# Oct, 11, 2013 DLANDIS - this file is now deprecated because dx_data_request_template_filter_components
#                         no longer exists :)   This file has been removed from the crontab.

# Sept, 23 2013 DLANDIS - this file set up to remove all rows from dx_data_request_template_filter_components
#                         that are not associated with any submitted requests AND are more than 24 hours old

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

psql $PORT -d $DB -c "
-- delete all rows of filter_componenents from data_requests that were never submitted and are greater than 1 day old
DELETE FROM dx_data_request_template_filter_components WHERE filter_id IN (
   -- grab all filter_id's from data_requests that were never submitted
   SELECT filter_id FROM dx_data_request_template_filters WHERE group_id IN (
      -- recursive query to grab all group_id's from data_requests that were never submitted
      WITH RECURSIVE allchildren(group_id, parent_group_id) AS (
         SELECT group_id, parent_group_id
         FROM dx_data_request_template_groups
         WHERE data_request_id IN (
            -- grab all data_request_id's that were never submitted
            SELECT data_request_id FROM dx_data_requests dr WHERE data_request_id > 457 AND date_submitted IS NULL ORDER BY data_request_id
         )
         UNION ALL
         SELECT drtg.group_id, drtg.parent_group_id
         FROM allchildren ac
         INNER JOIN dx_data_request_template_groups drtg ON ac.group_id = drtg.parent_group_id
      )
      SELECT group_id
      FROM allchildren
      ORDER BY group_id
   )
)
AND date_added < now() - interval '1 day';
"

psql $PORT -d $DB -c "VACUUM ANALYZE dx_data_request_template_filter_components;"

echo 'finished';
