#!/bin/bash
set -e

echo "Container ps..."
docker ps -a

echo "Container down..."
docker compose down

echo "Container ps..."
docker ps -a
