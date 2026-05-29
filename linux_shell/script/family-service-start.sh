#!/bin/bash

set -e

cd /home/jaewoo/projects/family-photo-service

# venv 활성화(실패하면 즉시 종료)
source .venv/bin/activate

# 활성화 확인(이게 찍히면 activate는 먹은 겁니다)
echo "[OK] python=$(which python)"
echo "[OK] uvicorn=$(which uvicorn)"

# 실행
exec uvicorn app.main:app --host 0.0.0.0 --port 8000
