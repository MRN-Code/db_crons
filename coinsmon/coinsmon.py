# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4 background=dark
import sys
import psycopg2
import psycopg2.extras
from datetime import datetime
from datetime import timedelta
from coinsmon_util import *

# Configuration section
admins="dlandis@mrn.org,dwood@mrn.org,wcourtney@mrn.org,rkelly@mrn.org,rwang@mrn.org,cdieringer@mrn.org"
dbname="postgres"
user="postgres"
port="6117"
#


msg=""

try:
    conn = psycopg2.connect("dbname="+dbname+" user="+user+" port="+port)
except:
    msg+="Error connecting to database:"+dbname+". " + str(sys.exc_info()[0])
    mail(msg,admins)
    sys.exit(msg)

try: 
    # check for long running queries
    highmark = '2 minutes'
    vaccuum_highmark = '30 minutes'
    excluded_users = 'QUICKDUMPBOT';

    dict_cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    dict_cur.execute("" + \
       "SELECT " + \
       "   a.*, " + \
       "   now()-xact_start as running_time " + \
       "FROM pg_stat_activity a " + \
       "WHERE procpid != pg_backend_pid() " + \
       "AND ( " + \
       "   /* warn 3 times between 0:02 and 0:17 */" + \
       "   (now()-xact_start > INTERVAL '2 minutes' " + \
       "    AND now()-xact_start < interval '17 minutes' " + \
       "    AND a.current_query NOT LIKE 'autovacuum%' " + \
       "    AND a.current_query NOT LIKE '<IDLE>%') " + \
       "   OR " + \
       "   /* warn 3 times between 3:02 and 3:17  */" + \
       "   (now()-xact_start > INTERVAL '182 minutes' " + \
       "    AND now()-xact_start < interval '197 minutes' " + \
       "    AND a.current_query NOT LIKE 'autovacuum%' " + \
       "    AND a.current_query NOT LIKE '<IDLE>%') " + \
       "   OR " + \
       "   /* warn constantly after 12 hours  */" + \
       "   (now()-xact_start > INTERVAL '12 hours' " + \
       "    AND a.current_query NOT LIKE 'autovacuum%' " + \
       "    AND a.current_query NOT LIKE '<IDLE>%') " + \
       "   OR " + \
       "   (a.current_query LIKE 'autovacuum%' " + \
       "    AND now()-xact_start > INTERVAL '"+vaccuum_highmark+"') " + \
       ") " + \
       "AND a.current_query NOT LIKE '%" + excluded_users + "%' " + \
       "ORDER BY running_time;")
    for record in dict_cur:
        if record['xact_start']!=None:
            if str(record['current_query']).startswith('autovacuum'):
                msg+="procpid: "+str(record['procpid'])+" started query@" +  \
                      str(record['xact_start']) + " and has been running longer than " + \
                      vaccuum_highmark  + "\n" + "current_query=" + record['current_query']
                msg+="\nRunning time = " + str(record['running_time']) + "s\n\n\n"
            else:
                msg+="procpid: "+str(record['procpid'])+" started query@" +  \
                      str(record['xact_start']) + " and has been running longer than " + \
                      highmark  + "\n" + "current_query=" + record['current_query']
                msg+="\nRunning time = " + str(record['running_time']) + "s\n\n\n"

    # check number of connections
    highmark = '.85'
    qry="select count(1) connection_count from pg_stat_activity"
    dict_cur.execute(qry)
    record=dict_cur.fetchone()
    current=record['connection_count']
    qry="select setting " + \
        "from pg_settings where name='max_connections';"
    dict_cur.execute(qry)
    record=dict_cur.fetchone()
    max=record['setting']
    pcnt=float(current)/float(max)
    if pcnt > float(highmark):
        msg+="number of connections is " + str(current) + " where maximum is " + \
             str(max) + " which is " + str(pcnt) + "% and greater than highmark" + \
             " of " + str(highmark) + "%\n"

    # check diskspace
    highmark = 90
    qry="select setting " + \
        "from pg_settings where name='data_directory';"
    dict_cur.execute(qry)
    record=dict_cur.fetchone()
    data_dir=record['setting']
    pcnt=freespace(str(data_dir))
    if pcnt > highmark:
        msg+="disk space on " + str(data_dir) + " is at " + str(pcnt) + "% which" + \
             " is greater than the highwater mark of " + str(highmark) + "%\n"

    dict_cur.close()
    conn.close()
    if msg!="":
       mail(msg,admins)
except:
    msg+="Error running script against "+dbname+". " + str(sys.exc_info()[0]) + "\n"
    mail(msg,admins)
    sys.exit(msg)

