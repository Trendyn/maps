#!/bin/sh

echo "mysql --host=$1 --user=oc  < create_db.sql;"
mysql --protocol=TCP --host=$1 --user=oc -p$2 < ./sql_scripts/create_db.sql;

echo "mysql --protocol=TCP --host=$1 --user=oc opinions < maps.sql;"
mysql --protocol=TCP --host=$1 --user=oc -p$2 opinions < ./maps/maps.sql;
                                                       
echo "mysql --host=$1 --user=oc opinions < create_tables.sql;"
mysql --protocol=TCP --host=$1 --user=oc -p$2 opinions < ./sql_scripts/create_tables.sql;

echo "mysql --host=$1 --user=oc opinions < create_stored_procedures.sql;"
mysql --protocol=TCP --host=$1 --user=oc -p$2 opinions < ./sql_scripts/create_stored_procedures.sql;
