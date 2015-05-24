#!/bin/sh

cd /var/lib/pgsql/permissions/login_permissions
TODAY=`date`
HOSTNAME=`hostname`;
echo $TODAY 
echo ""
DB="coins"

# Set DB and server names based on which server the file is located

echo "A prettier version of this email can be seen on $HOSTAME at /var/log/pgsql/permissions/login_permissions/changes"
echo ""
#echo "This file is to be used for testing permissions"
echo "This is a cron job running on $HOSTNAME at /var/lib/pgsql/permissions/login_permissions/test_permissions.sh"
#echo "The script is actually run by permissions_driver.sh"
#echo ""

# Define File locations
FINAL="final.txt"
PREV_FINAL="prev_final.txt"

FUNCTION="text_files/function.txt"
VIEW="text_files/view.txt"
TABLE="text_files/table.txt"

PUBLIC="public.txt"
CAS="cas_app.txt"
LOGIN="login_app.txt"
MICIS="micis_app.txt"
NIF="nif_user.txt"
P2="p2_app.txt"
PORTAL="portal_app.txt"

F_LOGINS="text_files/logins.txt"
F_FINAL="functions_cat.txt.new"
T_FINAL="table_cat.txt.new" 
V_FINAL="view_cat.txt.new"

# -d   d:defines database name
# -o   o:outputs response to file specified
# -tAc t:turns of printing columns/headers 
#      A:switches to unaligned output mode 
#      c:specifies to execute following command

#FUNCTIONS
psql -d $DB -o public.txt -tAc "SELECT COUNT(1) FROM information_schema.routine_privileges WHERE grantee = 'PUBLIC';"
psql -d $DB -o cas_app.txt -tAc "SELECT COUNT(1) FROM information_schema.routine_privileges WHERE grantee = 'cas_app';"
psql -d $DB -o login_app.txt -tAc "SELECT COUNT(1) FROM information_schema.routine_privileges WHERE grantee = 'login_app';"
psql -d $DB -o micis_app.txt -tAc "SELECT COUNT(1) FROM information_schema.routine_privileges WHERE grantee = 'micis_app';"
psql -d $DB -o nif_user.txt -tAc "SELECT COUNT(1) FROM information_schema.routine_privileges WHERE grantee = 'nif_user';"
psql -d $DB -o p2_app.txt -tAc "SELECT COUNT(1) FROM information_schema.routine_privileges WHERE grantee = 'p2_app';"
psql -d $DB -o portal_app.txt -tAc "SELECT COUNT(1) FROM information_schema.routine_privileges WHERE grantee = 'portal_app';"

cat $FUNCTION $PUBLIC $CAS $LOGIN $MICIS $NIF $P2 $PORTAL >> functions_cat.txt
sed -e :a -e '$!N;s/\n/\t\t/;ta' functions_cat.txt > functions_cat.txt.new

#TABLES
psql -d $DB -o public.txt -tAc "SELECT COUNT(DISTINCT tp.table_name) FROM information_schema.table_privileges tp INNER JOIN information_schema.tables t ON tp.table_name = t.table_name WHERE tp.table_schema NOT IN ('pg_catalog', 'information_schema') AND table_type = 'BASE TABLE' AND grantee = 'PUBLIC';"
psql -d $DB -o cas_app.txt -tAc "SELECT COUNT(DISTINCT tp.table_name) FROM information_schema.table_privileges tp INNER JOIN information_schema.tables t ON tp.table_name = t.table_name WHERE tp.table_schema NOT IN ('pg_catalog', 'information_schema') AND table_type = 'BASE TABLE' AND grantee = 'cas_app';"
psql -d $DB -o login_app.txt -tAc "SELECT COUNT(DISTINCT tp.table_name) FROM information_schema.table_privileges tp INNER JOIN information_schema.tables t ON tp.table_name = t.table_name WHERE tp.table_schema NOT IN ('pg_catalog', 'information_schema') AND table_type = 'BASE TABLE' AND grantee = 'login_app';"
psql -d $DB -o micis_app.txt -tAc "SELECT COUNT(DISTINCT tp.table_name) FROM information_schema.table_privileges tp INNER JOIN information_schema.tables t ON tp.table_name = t.table_name WHERE tp.table_schema NOT IN ('pg_catalog', 'information_schema') AND table_type = 'BASE TABLE' AND grantee = 'micis_app';"
psql -d $DB -o nif_user.txt -tAc "SELECT COUNT(DISTINCT tp.table_name) FROM information_schema.table_privileges tp INNER JOIN information_schema.tables t ON tp.table_name = t.table_name WHERE tp.table_schema NOT IN ('pg_catalog', 'information_schema') AND table_type = 'BASE TABLE' AND grantee = 'nif_user';"
psql -d $DB -o p2_app.txt -tAc "SELECT COUNT(DISTINCT tp.table_name) FROM information_schema.table_privileges tp INNER JOIN information_schema.tables t ON tp.table_name = t.table_name WHERE tp.table_schema NOT IN ('pg_catalog', 'information_schema') AND table_type = 'BASE TABLE' AND grantee = 'p2_app';"
psql -d $DB -o portal_app.txt -tAc "SELECT COUNT(DISTINCT tp.table_name) FROM information_schema.table_privileges tp INNER JOIN information_schema.tables t ON tp.table_name = t.table_name WHERE tp.table_schema NOT IN ('pg_catalog', 'information_schema') AND table_type = 'BASE TABLE' AND grantee = 'portal_app';"

cat $TABLE $PUBLIC $CAS $LOGIN $MICIS $NIF $P2 $PORTAL >> table_cat.txt
sed -e :a -e '$!N;s/\n/\t\t/;ta' table_cat.txt > table_cat.txt.new

#VIEWS
psql -d $DB -o public.txt -tAc "SELECT COUNT(DISTINCT tp.table_name) FROM information_schema.table_privileges tp INNER JOIN information_schema.tables t ON tp.table_name = t.table_name WHERE tp.table_schema NOT IN ('pg_catalog', 'information_schema') AND table_type = 'VIEW' AND grantee = 'PUBLIC';"
psql -d $DB -o cas_app.txt -tAc "SELECT COUNT(DISTINCT tp.table_name) FROM information_schema.table_privileges tp INNER JOIN information_schema.tables t ON tp.table_name = t.table_name WHERE tp.table_schema NOT IN ('pg_catalog', 'information_schema') AND table_type = 'VIEW' AND grantee = 'cas_app';"
psql -d $DB -o login_app.txt -tAc "SELECT COUNT(DISTINCT tp.table_name) FROM information_schema.table_privileges tp INNER JOIN information_schema.tables t ON tp.table_name = t.table_name WHERE tp.table_schema NOT IN ('pg_catalog', 'information_schema') AND table_type = 'VIEW' AND grantee = 'login_app';"
psql -d $DB -o micis_app.txt -tAc "SELECT COUNT(DISTINCT tp.table_name) FROM information_schema.table_privileges tp INNER JOIN information_schema.tables t ON tp.table_name = t.table_name WHERE tp.table_schema NOT IN ('pg_catalog', 'information_schema') AND table_type = 'VIEW' AND grantee = 'micis_app';"
psql -d $DB -o nif_user.txt -tAc "SELECT COUNT(DISTINCT tp.table_name) FROM information_schema.table_privileges tp INNER JOIN information_schema.tables t ON tp.table_name = t.table_name WHERE tp.table_schema NOT IN ('pg_catalog', 'information_schema') AND table_type = 'VIEW' AND grantee = 'nif_user';"
psql -d $DB -o p2_app.txt -tAc "SELECT COUNT(DISTINCT tp.table_name) FROM information_schema.table_privileges tp INNER JOIN information_schema.tables t ON tp.table_name = t.table_name WHERE tp.table_schema NOT IN ('pg_catalog', 'information_schema') AND table_type = 'VIEW' AND grantee = 'p2_app';"
psql -d $DB -o portal_app.txt -tAc "SELECT COUNT(DISTINCT tp.table_name) FROM information_schema.table_privileges tp INNER JOIN information_schema.tables t ON tp.table_name = t.table_name WHERE tp.table_schema NOT IN ('pg_catalog', 'information_schema') AND table_type = 'VIEW' AND grantee = 'portal_app';"

cat $VIEW $PUBLIC $CAS $LOGIN $MICIS $NIF $P2 $PORTAL >> view_cat.txt
sed -e :a -e '$!N;s/\n/\t\t/;ta' view_cat.txt > view_cat.txt.new

#WRAP UP
cat $F_LOGINS $F_FINAL $T_FINAL $V_FINAL >> final.txt

# cp previous final.txt file to permissions directory for comparison purposes
cd finals
cp -r `ls --sort=time|head -1` ../prev_final.txt
cd ../

# do the comparison
if diff prev_final.txt final.txt >/dev/null 
then
	echo "Same"
else
  	SAVE_FILE=Y
  	echo ""
        #echo "Different"
fi

echo ""
echo "PREVIOUS Permissions"
cat $PREV_FINAL
echo ""
echo "NEW Permissions"
cat $FINAL

# if different, name the new final.txt file with the date and put in the finals directory
if test "$SAVE_FILE" = "Y"
then
	d=`date +%Y%m%d%H%M%S`
	f="finals/${d}_final.txt"
	a="final.txt"
	cp $a $f
fi

rm prev_final.txt final.txt functions_cat.txt functions_cat.txt.new  view_cat.txt view_cat.txt.new table_cat.txt table_cat.txt.new public.txt cas_app.txt login_app.txt micis_app.txt nif_user.txt p2_app.txt portal_app.txt

#echo ""
#echo "finished"
echo ""
TODAY=`date`
echo $TODAY

