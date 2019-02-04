#!/bin/bash

sed -i 's|"db": "peq"|"db": "'${MARIADB_DATABASE}'"|g' server/eqemu_config.json
sed -i 's|"host": "mariadb"|"host": "'${MARIADB_HOST}'"|g' server/eqemu_config.json
sed -i 's|"port": "3306"|"port": "'${MARIADB_PORT}'"|g' server/eqemu_config.json
sed -i 's|"username": "eqemu"|"username": "'${MARIADB_USER}'"|g' server/eqemu_config.json
sed -i 's|"password": "eqemu"|"password": "'${MARIADB_PASSWORD}'"|g' server/eqemu_config.json

