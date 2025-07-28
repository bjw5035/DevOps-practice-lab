#!/bin/bash

# 대기 간격 (초)
INTERVAL=5

# 대기할 최대 시간 (초) — 원하면 제한 없이 하려면 이 부분 제거
TIMEOUT=300
START_TIME=$(date +%s)

echo "모든 파드가 Ready 상태가 될 때까지 대기 중입니다..."

while true; do
	# 현재클러스터의 모든 파드 상태를 조회
	pods=$(kubectl get pods --all-namespaces)
	
	# Ready 상태가 아닌 파드가 있는지 확인
	not_ready=$(echo "$pods" | awk 'NR>1 {if($4 != $2) print $0}')

	if [[ -z "$not_ready" ]]; then
		echo "모든 파드가 Ready 상태입니다."
		break
	else
		echo "아직 준비되지 않은 파드가 존재합니다. ${INTERVAL}초 후 다시 확인합니다..."
        	echo "$not_ready"
	fi

	# 최대 대기 시간 초과 여부 확인
	if [[ $TIMEOUT -gt 0 ]]; then
		NOW=$(date +%s)
		ELAPSED=$((NOW - START_TIME))
		if [[ $ELAPSED -ge $TIMEOUT ]]; then
			echo "대기 시간 초과 (${TIMEOUT}초). 아직 Ready되지 않은 파드가 있습니다."
            		exit 1
        	fi
	fi

	sleep $INTERVAL
done
