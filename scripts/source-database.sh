#!/usr/bin/env bash

mysql -h mariadb -u root -proot -e "DROP DATABASE peq; CREATE DATABASE peq; GRANT ALL PRIVILEGES ON  peq.* to 'eqemu'@'%' WITH GRANT OPTION;"
