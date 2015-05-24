#run_stats
#
# <c)2010 MIND Institute
#
# Intended to be called from crond
# called daily at 0:21 by /etc/cron.d/coins
echo "Starting run_stats at"
date
psql << EOF
\o run_stats.log
select now();
\i run_stats.sql
select now();
\q
EOF

echo "done"
date

