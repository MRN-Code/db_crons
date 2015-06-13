#!/bin/sh

cd /coins/db_crons/permissions/sec_definers
TODAY=`date`
HOSTNAME=`hostname`
DB="coins"
echo $TODAY 
echo ""

echo "This cronjob is running from $HOSTNAME db_crons/permissions/sec_definers"
echo ""
echo "Hint: to make a function have security_type DEFINER... see these examples:"
echo "During function creation: LANGUAGE plpgsql VOLATILE SECURITY DEFINER"
echo "After the fact: ALTER FUNCTION mrsdba.mrs_add_dx_data_request_f(text, numeric) SECURITY DEFINER"

# Define File locations
FUNC_FINAL="func_final.txt"
PREV_FUNC_FINAL="prev_func_final.txt"

F_SCHEMA="text_files/schema.txt"
MRSDBA="text_files/mrsdba.txt"
CASDBA="text_files/casdba.txt"
PUBLIC="text_files/public.txt"

TOTAL="total.txt"
DEF="def.txt"

M_FINAL="mrs_func_cat.txt.new"
C_FINAL="cas_func_cat.txt.new"
P_FINAL="pub_func_cat.txt.new"

# -d   d:defines database name
# -o   o:outputs response to file specified
# -tAc t:turns of printing columns/headers 
#      A:switches to unaligned output mode 
#      c:specifies to execute following command

#COUNT TOTAL FUNCTIONS AND FUNCTIONS WITH SECURITY_TYPE=DEFINER: mrsdba
psql -d $DB -o total.txt -tAc "SELECT COUNT(1) FROM information_schema.routines WHERE routine_schema = 'mrsdba';"
psql -d $DB -o def.txt -tAc "SELECT COUNT(1) FROM information_schema.routines WHERE routine_schema = 'mrsdba' AND security_type = 'DEFINER';"

cat $MRSDBA $TOTAL $DEF >> mrs_func_cat.txt
sed -e :a -e '$!N;s/\n/\t\t/;ta' mrs_func_cat.txt > mrs_func_cat.txt.new

#COUNT TOTAL FUNCTIONS AND FUNCTIONS WITH SECURITY_TYPE=DEFINER: casdba
psql -d $DB -o total.txt -tAc "SELECT COUNT(1) FROM information_schema.routines WHERE routine_schema = 'casdba';"
psql -d $DB -o def.txt -tAc "SELECT COUNT(1) FROM information_schema.routines WHERE routine_schema = 'casdba' AND security_type = 'DEFINER';"

cat $CASDBA $TOTAL $DEF >> cas_func_cat.txt
sed -e :a -e '$!N;s/\n/\t\t/;ta' cas_func_cat.txt > cas_func_cat.txt.new

#COUNT TOTAL FUNCTIONS AND FUNCTIONS WITH SECURITY_TYPE=DEFINER: public
psql -d $DB -o total.txt -tAc "SELECT COUNT(1) FROM information_schema.routines WHERE routine_schema = 'public';"
psql -d $DB -o def.txt -tAc "SELECT COUNT(1) FROM information_schema.routines WHERE routine_schema = 'public' AND security_type = 'DEFINER';"

cat $PUBLIC $TOTAL $DEF >> pub_func_cat.txt
sed -e :a -e '$!N;s/\n/\t\t/;ta' pub_func_cat.txt > pub_func_cat.txt.new


#WRAP UP
cat $F_SCHEMA $M_FINAL $C_FINAL $P_FINAL >> func_final.txt

# cp previous func_final.txt file to permissions directory for comparison purposes
cd finals
cp -r `ls --sort=time|head -1` ../prev_func_final.txt
cd ../

# do the comparison
if diff prev_func_final.txt func_final.txt >/dev/null
then
        echo "Same"
else
        SAVE_FILE=Y
        echo ""
        #echo "Different"
fi

echo ""
echo "PREVIOUS Function/Definer Numbers"
cat $PREV_FUNC_FINAL
echo ""
echo "NEW Function/Definer Numbers"
cat $FUNC_FINAL

# if different, name the new final.txt file with the date and put in the finals directory
if test "$SAVE_FILE" = "Y"
then
        d=`date +%Y%m%d%H%M%S`
        f="finals/${d}_func_final.txt"
        a="func_final.txt"
        cp $a $f
fi

rm total.txt def.txt mrs_func_cat.txt mrs_func_cat.txt.new cas_func_cat.txt cas_func_cat.txt.new pub_func_cat.txt pub_func_cat.txt.new func_final.txt prev_func_final.txt

#echo ""
#echo "finished"
echo ""
TODAY=`date`
echo $TODAY

exit
