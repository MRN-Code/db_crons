# Dump production rep database to network storage

## crons
- coins_rep_dump
    - dumps the entire COINS database over a single file, nightly, ~~midnight
        - running versions are not maintained as redundant backups are already performed by `barman`
- coins_rep_dump_query_temp
    - dumps only tables necessary to support query builder in pg8.4 as the ENG team investigates slow QB performance on pg 9.x

Place coins_rep_dump file in /etc/cron.d/
