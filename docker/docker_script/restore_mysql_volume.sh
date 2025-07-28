#!/bin/bash

VOLUME_NAME=mysql-data
BACKUP_FILE=$1

if [ ! -f "$BACKUP_FILE" ]; then
	echo "❌ 백업 파일이 존재하지 않습니다: $BACKUP_FILE"
	exit 1
fi

echo "⚠️ 복원 시 기존 데이터가 덮어씌워집니다. Enter로 계속..."
read

docker run --rm \
	-v $VOLUME_NAME:/volume \
	-v $PWD:/backup \
	alpine \
	sh -c "rm -rf /volume/* && tar -xzf /backup/$(basename $BAKCUP_FILE) -C /volume"

echo "✅ 복원 완료"
