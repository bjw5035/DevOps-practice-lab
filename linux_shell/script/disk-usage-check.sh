#!/usr/bin/env bash

set -u
# set -o pipefail

readonly SCRIPT_NAME="$(basename "$0")"

print_usage() {
    cat <<EOF
Usage:
  $SCRIPT_NAME [MOUNT_POINT] [THRESHOLD]

Examples:
  $SCRIPT_NAME
  $SCRIPT_NAME / 80
  $SCRIPT_NAME /home 90

Exit codes:
  0  Disk usage is below threshold
  1  Disk usage is greater than or equal to threshold
  2  Invalid argument or execution error
EOF
}

#is_number() {
#    local value="$1"
#
#    [[ "$value" =- ^[0-9]+$ ]]
#}

main() {
    local mount_point="${1:-/}"
    local threshold="${2:-80}"
    local usage_percent

    if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
        print_usage
        exit 0
    fi

    if [[ ! -d "$mount_point" ]]; then
        printf '[ERROR] Mount point or directory does not exist: %s\n' "$mount_point" >&2
        exit 2
    fi

#    if ! is_number "$threshold"; then
#        printf '[ERROR] Threshold must be a number: %s\n' "$threshold" >&2
#        exit 2
#    fi

    if (( threshold < 1 || threshold > 100 )); then
        printf '[ERROR] Threshold must be between 1 and 100: %s\n' "$threshold" >&2
        exit 2
    fi

    usage_percent="$(
        df -P "$mount_point" 2>/dev/null |
            awk 'NR==2 { gsub("%", "", $5); print $5 }'
    )"

    if [[ -z "$usage_percent" ]]; then
        printf '[ERROR] Failed to get disk usage for: %s\n' "$mount_point" >&2
        exit 2
    fi

    if (( usage_percent >= threshold )); then
        printf '[WARNING] %s usage: %s%% (threshold: %s%%)\n' \
            "$mount_point" "$usage_percent" "$threshold"
        exit 1
    fi

    printf '[OK] %s usage: %s%% (threshold: %s%%)\n' \
        "$mount_point" "$usage_percent" "$threshold"
    exit 0
}

main "$@"
