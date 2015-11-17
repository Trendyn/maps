#!/bin/sh

echo "mysql --host=localhost --user=root  < create_db.sql;"
mysql --protocol=TCP --host=localhost --user=root  < sql_scripts/create_db.sql;

echo "mysql --host=localhost --user=root opinions < create_tables.sql;"
mysql --protocol=TCP --host=localhost --user=root  opinions < ./sql_scripts/create_tables.sql;

echo "mysql --host=localhost --user=root opinions < create_stored_procedures.sql;"
mysql --protocol=TCP --host=localhost --user=root opinions < ./sql_scripts/create_stored_procedures.sql;
