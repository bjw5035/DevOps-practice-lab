#!/bin/bash
set -e

echo "Containser ps.."
docker ps -a

echo "Container up..."
docker compose up -d --build

echo "Container ps..."
docker ps -a
