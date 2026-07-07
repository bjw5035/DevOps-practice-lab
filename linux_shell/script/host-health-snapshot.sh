#!/usr/bin/bash

# 정의되지 않은 변수를 사용하면 오류로 처리
set -u

# 파이프라인 중간 명령이 실패해도 실패 상태를 인식
set -o pipefail

readonly RED=$'\033[1;31m'
readonly GREEN=$'\033[1;32m'
readonly YELLOW=$'\033[1;33m'
readonly CYAN=$'\033[1;36m'
readonly RESET=$'\033[0m'

readonly SCRIPT_NAME="$(basename "$0")"
readonly CURRENT_TIME="$(date '+%Y-%m-%d %H:%M:%S')"
readonly HOST_NAME="$(hostname)"

# 출력 구간을 구분하는 함수
print_section() {
    local title="$1"

    printf '\n'
    printf '==================================================\n'
    printf '%s\n' "$title"
    printf '==================================================\n'
}

main() {
    print_warning_section "HOST HEALTH SNAPSHOT"

    printf 'Script      : %s\n' "$SCRIPT_NAME"
    printf 'Hostname    : %s\n' "$HOST_NAME"
    printf 'Time        : %s\n' "$CURRENT_TIME"

    # TODO: 시스템 기본 정보
    print_warning_section "SYSTEM INFORMATION"

    printf 'Kernel          : %s\n' "$(uname -r)"
    printf 'Architecture    : %s\n' "$(uname -m)"
    printf 'Uptime          : %s\n' "$(uptime -p)"


    # TODO: CPU 및 Load Average
    print_warning_section "CPU AND LOAD AVERAGE"

    printf 'CPU cores                   : %s\n' "$(nproc)"
    printf 'Load average (1m 5m 15m)    : %s\n' \
        "$(awk '{print $1, $2, $3}' /proc/loadavg)"

    # TODO: 메모리 사용량
    print_warning_section "MEMORY USAGE"
    free -h

    # TODO: 디스크 사용량
    print_warning_section "DISK USAGE"
    df -h

    # TODO: CPU/메모리 상위 프로세스
    print_warning_section "TOP 5 PROCESSES BY CPU"

    ps -eo pid,user,%cpu,%mem,comm \
        --sort=-%cpu | head -n 6

    print_warning_section "TOP 5 PROCESSES BY MEMORY"

    ps -eo pid,user,%mem,%cpu,comm \
        --sort=-%mem | head -n 6


    # TODO: LISTEN 포트
    print_warning_section "LISTEN PORTS"
    ss -ntlp | grep "LISTEN"

    # TODO: 실패한 systemd 서비스
    print_warning_section "FAILED SYSTEMD SERVICES"
    systemctl --failed --no-pager 

}

print_warning_section(){
    local title="$1"

    printf '\n'
    printf '%s============================================================%s\n' \
        "$RED" "$RESET"
    printf '%s%s%s\n' \
        "$RED" "$title" "$RESET"
    printf '%s============================================================%s\n' \
        "$RED" "$RESET"
}


main "$@"
