#!/usr/bin/env bash
# ↑ bash 위치가 서버마다 다를 수 있으므로 env를 통해 bash를 찾음 (이식성 ↑)

set -euo pipefail
# -e : 명령어 하나라도 실패(exit code != 0)하면 즉시 종료
# -u : 선언되지 않은 변수 사용 시 즉시 종료 (오타/실수 방지)
# -o pipefail : 파이프라인(|) 중 앞 명령 실패도 실패로 인식

############################
# 설정 값 (환경별로 조정)
############################

IMAGE_NAME="family-photo-service"
# Docker 이미지 이름

IMAGE_TAG="${IMAGE_TAG:-latest}"
# IMAGE_TAG 환경변수가 있으면 그 값을 사용
# 없으면 기본값 latest 사용
# 예) IMAGE_TAG=20251223-1 ./docker-image-build.sh

DEPLOYMENT_NAME="${DEPLOYMENT_NAME:-family-photo-service}"
# 재기동할 Kubernetes Deployment 이름

NAMESPACE="${NAMESPACE:-default}"
# Kubernetes 네임스페이스 (기본 default)

############################
# 실행 로직
############################

echo "[1/4] Docker image build started"
echo "      Image: ${IMAGE_NAME}:${IMAGE_TAG}"

# Dockerfile 기반 이미지 재빌드
# 코드 변경 사항을 컨테이너 이미지에 반영하는 단계
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .

echo "[2/4] Kubernetes deployment rollout restart"
echo "      Deployment: ${DEPLOYMENT_NAME}"
echo "      Namespace : ${NAMESPACE}"

# Deployment를 재기동하여 새 이미지 사용하도록 강제
# (replicaset 새로 생성 → pod 교체)
kubectl -n "${NAMESPACE}" rollout restart "deployment/${DEPLOYMENT_NAME}"

echo "[3/4] Waiting for rollout to complete..."

# rollout이 실제로 완료될 때까지 대기
# 중간에 실패하면 set -e에 의해 스크립트 즉시 종료
kubectl -n "${NAMESPACE}" rollout status "deployment/${DEPLOYMENT_NAME}" --timeout=120s

echo "[4/4] Current pod status"

# 현재 Pod 상태 확인
# AGE, IP, NODE 확인용 (운영 점검)
kubectl -n "${NAMESPACE}" get pods -o wide

echo "✔ Deployment completed successfully"

