#!/bin/bash
set -e

echo "📦 백업 시작..."
./backup_mysql_volume.sh

echo "Pull latest code..."
git pull

echo "Run Docker..."
docker compose down
docker compose up -d --build

echo "Docker ps..."
docker ps -a
