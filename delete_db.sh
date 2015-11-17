#!/bin/sh

echo "mysql --user=root --password=$1 < delete_db.sql;"
mysql --user=root --password=$1 < delete_db.sql;
