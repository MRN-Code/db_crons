# DWOOD May, 24 2015: Having trouble getting this to run in our new environment. 
# Perhaps due to missing python deps
# Wish to re-write in node before this goes into production
 
These rely on a properly configure python environment for use with Postgresql.

The following commands were used to create this environment on
nirepdb and nidb
==============================================================================
sudo yum install gcc
sudo yum install python-devel
sudo yum install --disablerepo=base --disablerepo=extras --disablerepo=updates postgresql-devel
sudo su - postgres
curl -O https://raw.github.com/pypa/virtualenv/master/virtualenv.py
python virtualenv.py postgres
. postgres/bin/activate
pip install psycopg
==============================================================================



  
