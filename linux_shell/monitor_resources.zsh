#!/usr/bin/env zsh

echo ">>> monitor_resources start"

INTERVAL=5

function print_stats() {
	local now=$(date '+%Y-%m-%d %H:%M:%S')

	local cpu_idle=$(top -bn1 | grep -i "CPU(s)" | awk '{print $8}' | sed 's/,/./')
	local cpu_usage=$(printf "%.1f%%" "$(echo "100 - $cpu_idle" | bc -l)")
	
	local mem_line=$(free -m | awk 'NR==2{print $3, $2}')
	local mem_used=$(echo $mem_line | cut -d' ' -f1)
	local mem_total=$(echo $mem_line | cut -d' ' -f2)
	local mem_pct=$(printf "%.1f%%" "$(echo "$mem_used*100/$mem_total" | bc -l)")
	
	local disk_info=$(df -h / | awk 'NR==2{print $5, $3, $2}')
	local disk_pct=$(echo $disk_info | cut -d' ' -f1)
	local disk_used=$(echo $disk_info | cut -d' ' -f2)
	local disk_total=$(echo $disk_info | cut -d' ' -f3)

	echo "[$now] CPU : $cpu_usage"
	echo " mem usage : $mem_pct (${mem_used}MB/${mem_total}MB)"
	echo " disk usage : $disk_pct (${disk_used}/${disk_total})"
	echo "=============================================="

}
	while true; do
		print_stats
		sleep $INTERVAL
	done

