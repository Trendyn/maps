#!/bin/sh

if [ "$1" = "localhost" ]; then
  echo "mysql --host=$1 --user=root  < create_db.sql;"
  mysql --protocol=TCP --host=$1 --user=root < ./sql_scripts/create_db.sql;

  echo "mysql --protocol=TCP --host=$1 --user=oc opinions < maps.sql;"
  mysql --protocol=TCP --host=$1 --user=root  opinions < ./maps/maps.sql;

  echo "mysql --host=$1 --user=oc opinions < create_tables.sql;"
  mysql --protocol=TCP --host=$1 --user=root  opinions < ./sql_scripts/create_tables.sql;

  echo "mysql --host=$1 --user=oc opinions < create_stored_procedures.sql;"
  mysql --protocol=TCP --host=$1 --user=root  opinions < ./sql_scripts/create_stored_procedures.sql;

else
  echo "mysql --host=$1 --user=$2  < create_db.sql;"
  mysql --protocol=TCP --host=$1 --user=$2 -p$3 < ./sql_scripts/create_db.sql;

  echo "mysql --protocol=TCP --host=$1 --user=oc opinions < maps.sql;"
  mysql --protocol=TCP --host=$1 --user=$2 -p$3 opinions < ./maps/maps.sql;

  echo "mysql --host=$1 --user=oc opinions < create_tables.sql;"
  mysql --protocol=TCP --host=$1 --user=$2 -p$3 opinions < ./sql_scripts/create_tables.sql;

  echo "mysql --host=$1 --user=oc opinions < create_stored_procedures.sql;"
  mysql --protocol=TCP --host=$1 --user=$2 -p$3 opinions < ./sql_scripts/create_stored_procedures.sql;
fi

