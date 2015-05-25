from __future__ import division
import os
import subprocess
def freespace(path):
   df = subprocess.Popen(["df", path], stdout=subprocess.PIPE)
   output = df.communicate()[0]
   percent = output.strip().split("\n")[-1].split()[-2]
   return float(percent.split('%')[0])
def mail(message,to):
   SENDMAIL = "mail" # sendmail location
   p = os.popen("mail -s 'WARNING' "+to, "w")
   p.write(message + "\n")
   p.write(".\n")
   p.write("\n")
   sts = p.close()
   if sts != 0:
      print "Sendmail exit status", sts
