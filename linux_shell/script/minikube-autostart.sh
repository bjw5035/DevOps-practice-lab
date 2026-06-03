#!bin/sh

set -euo pipefail

# systemd에서 실행될 때 PATH가 부족할 수 있으므로 명시
export PATH="/usr/local/bin:/usr/bin:/bin:/snap/bin"

# minikube가 이미 실행 중이면 중복 실행하지 않음
if minikube status >/dev/null 2>&1; then
    echo "minikube is already running"
    exit 0
fi

# Docker 드라이버로 minikube 시작
minikube start --driver=docker

# 상태 확인
kubectl get nodes


