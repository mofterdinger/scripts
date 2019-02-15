#!/bin/bash
set -x

GUACD_NAME=my-guacd
GUACAMOLE_NAME=my-guacamole
MYSQL_NAME=guac-mysql
MYSQL_DB_NAME=guacamole
MYSQL_USER=guacamole
MYSQL_PASSWORD=my-secret
SCRIPT_DIR=$(pwd)/guacamole

docker stop $GUACAMOLE_NAME
docker rm  $GUACAMOLE_NAME

docker stop  $GUACD_NAME
docker rm  $GUACD_NAME

docker stop  $MYSQL_NAME
docker rm  $MYSQL_NAME

mkdir -p $SCRIPT_DIR
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql > $SCRIPT_DIR/initdb.sql

docker run --name $GUACD_NAME -d --restart always guacamole/guacd

# start MySQL 8.x  database
docker run --name $MYSQL_NAME \
	-e MYSQL_ROOT_PASSWORD="$MYSQL_PASSWORD" \
	-e MYSQL_DATABASE="$MYSQL_DB_NAME" \
	-e MYSQL_USER="$MYSQL_USER" \
	-e MYSQL_PASSWORD="$MYSQL_PASSWORD" \
	-v $SCRIPT_DIR:/docker-entrypoint-initdb.d \
	--restart always \
	-d mysql:8

# start Guacamole
docker run --name $GUACAMOLE_NAME \
	--link $GUACD_NAME:guacd \
	--link $MYSQL_NAME:mysql \
	-e MYSQL_DATABASE="$MYSQL_DB_NAME" \
	-e MYSQL_USER="$MYSQL_USER" \
	-e MYSQL_PASSWORD="$MYSQL_PASSWORD" \
	--restart always \
	-d -p 8080:8080 guacamole/guacamole

docker ps

docker logs $MYSQL_NAME -f

docker logs $GUACAMOLE_NAME -f
