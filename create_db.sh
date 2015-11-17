#!/bin/sh

echo "mysql --host=localhost --user=root  < create_db.sql;"
mysql --protocol=TCP --host=localhost --user=root  < sql_scripts/create_db.sql;
