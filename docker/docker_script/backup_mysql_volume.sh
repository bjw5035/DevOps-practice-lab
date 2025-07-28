#!/bin/bash

VOLUME_NAME=mysql-data
BACKUP_DIR=./mysql_volume_backups
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE=$BACKUP_DIR/${VOLUME_NAME}_$DATE.tar.gz

mkdir -p $BACKUP_DIR

docker run --rm \
	-v $VOLUME_NAME:/volume \
	-v $PWD/$BACKUP_DIR:/backup \
	alpine \
	tar -czf /backup/$(basename $BACKUP_FILE) -C /volume .

echo "✅ MySQL 볼륨 백업 완료: $BACKUP_FILE"
