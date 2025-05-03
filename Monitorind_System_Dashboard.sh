#!/bin/bash

system_monitor_dashboard() {
  cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}')
  cpu_usage=$(awk "BEGIN {print 100 - $cpu_idle}")
  cpu_int=${cpu_usage%.*}
  cpu_bar=$(draw_bar $cpu_int)
  load_avg=$(uptime | awk -F'load average: ' '{print $2}')

  mem_total=$(free -m | awk '/Mem:/ {print $2}')
  mem_used=$(free -m | awk '/Mem:/ {print $3}')
  mem_percent=$((mem_used * 100 / mem_total))
  mem_bar=$(draw_bar $mem_percent)

  disk_percent=$(df / | awk 'END {print $5}' | tr -d '%')
  disk_bar=$(draw_bar $disk_percent)
  var_usage=$(df /var 2>/dev/null | awk 'END {print $5}' | tr -d '%')
  [ -z "$var_usage" ] && var_usage="N/A"

  echo "+----------------------------------------------------------------------------------+"
  echo "|                         SYSTEM MONITOR DASHBOARD                                 |"
  echo "+----------------------------------------------------------------------------------+"
  printf "| CPU Usage:   %-22s %3s%%       Load Avg: %-23s |\n" "$cpu_bar" "$cpu_int" "$load_avg"
  printf "| Memory:      %-22s %3s%%       Swap: %-5s / %-5s MB            |\n" \
    "$mem_bar" "$mem_percent" "$(free -m | awk '/Swap:/ {print $3}')" "$(free -m | awk '/Swap:/ {print $2}')"
  printf "| Disk:        %-22s %3s%%       Warning: /var %s%% used            |\n" \
    "$disk_bar" "$disk_percent" "$var_usage"
  echo "+----------------------------------------------------------------------------------+"
}

display_top_processes() {
  echo "+----------------------------------------------------------------------------------+"
  echo "| Top Processes (CPU & Mem)                                                        |"
  echo "|----------------------------------------------------------------------------------|"
  printf "| %-2s | %-16s | %-8s | %-45s |\n" "#" "Process Name" "CPU (%)" "Memory (MB)"
  echo "|----------------------------------------------------------------------------------|"
  ps -eo pid,comm,%cpu,%mem,rss --sort=-%cpu | head -n 11 | tail -n 10 | awk '{
      printf "| %-2s | %-16s | %-8s | %-45.4f |\n", NR, $2, $3, $5/1024
  }'
  echo "+----------------------------------------------------------------------------------+"
}

display_network_stats() {
  interface="ens160"  # Change to your interface like enp0s3 if needed
  active_connections=$(netstat -an | grep ESTABLISHED | wc -l)
  packet_drops=$(cat /proc/net/dev | grep $interface | awk '{print $4}')
  data_in=$(cat /proc/net/dev | grep $interface | awk '{print $3}')
  data_out=$(cat /proc/net/dev | grep $interface | awk '{print $11}')
  data_in_gb=$(echo "scale=2; $data_in / 1024 / 1024 " | bc)
  data_out_gb=$(echo "scale=2; $data_out / 1024 / 1024 " | bc)

  echo "+----------------------------------------------------------------------------------+"
  echo "| Network Monitoring                                                               |"
  echo "|----------------------------------------------------------------------------------|"
  printf "| %-26s | %-51s |\n" "Active Connections: $active_connections" "Packet Drops: ${packet_drops:-0}"
  printf "| %-26s | %-51s |\n" "Data In: ${data_in_gb}GB" "Data Out: ${data_out_gb}GB"
  echo "+----------------------------------------------------------------------------------+"
}

display_disk_usage() {
  echo "+----------------------------------------------------------------------------------+"
  echo "| Disk Usage                                                                       |"
  echo "|----------------------------------------------------------------------------------|"
  printf "| %-20s | %-10s | %-44s |\n" "Partition" "Used (%)" "Mount Point"
  echo "|----------------------------------------------------------------------------------|"
  df -h | grep -vE '^Filesystem|tmpfs|cdrom' | while read line; do
    partition=$(echo $line | awk '{print $1}')
    used_percent=$(echo $line | awk '{print $5}' | sed 's/%//')
    mount_point=$(echo $line | awk '{print $6}')
    if [ $used_percent -gt 80 ]; then
      printf "\e[31m| %-20s | %-10s | %-44s |\e[0m\n" "$partition" "$used_percent%" "$mount_point"
    else
      printf "| %-20s | %-10s | %-44s |\n" "$partition" "$used_percent%" "$mount_point"
    fi
  done
  echo "+----------------------------------------------------------------------------------+"
}

display_system_load() {
  echo "+----------------------------------------------------------------------------------+"
  echo "| System Load                                                                      |"
  echo "|----------------------------------------------------------------------------------|"
  load_avg=$(uptime | awk -F'load average: ' '{print $2}')
  printf "| Load Average (1, 5, 15 min): %-38s              |\n" "$load_avg"
  echo "|----------------------------------------------------------------------------------|"
  cpu_line=$(top -bn1 | grep "%Cpu(s)")
  usre=$(echo "$cpu_line" | awk '{print $2}')
  system=$(echo "$cpu_line" | awk '{print $4}')
  idle=$(echo "$cpu_line" | awk '{print $8}')
  nice=$(echo "$cpu_line" | awk '{print $6}')
  iowait=$(echo "$cpu_line" | awk '{print $10}')
  hardwareinterrupts=$(echo "$cpu_line" | awk '{print $12}')
  softwareinterrupts=$(echo "$cpu_line" | awk '{print $14}')
  stealtime=$(echo "$cpu_line" | awk '{print $16}')
  printf "| User: %-30s | System: %-33s |\n" "$usre%" "$system%" 
  printf "| Idle: %-30s | Nice: %-35s |\n" "$idle%" "$nice%"
  printf "| IOWait: %-28s | StealTime: %-31s| \n" "$iowait%" "$stealtime%"
  printf "| Hardware Interrupts : %-14s | Software Interrupts: %-20s | \n" "$hardwareinterrupts%" "$softwareinterrupts%" 
  echo "+----------------------------------------------------------------------------------+"
}

display_memory_usage() {
  echo "+----------------------------------------------------------------------------------+"
  echo "| Memory Usage                                                                     |"
  echo "|----------------------------------------------------------------------------------|"
  mem_info=$(free -m)
  mem_line=$(echo "$mem_info" | grep -i "^Mem:")
  swap_line=$(echo "$mem_info" | grep -i "^Swap:")

  total_mem=$(echo "$mem_line" | awk '{print $2}')
  used_mem=$(echo "$mem_line" | awk '{print $3}')
  free_mem=$(echo "$mem_line" | awk '{print $4}')

  total_swap=$(echo "$swap_line" | awk '{print $2}')
  used_swap=$(echo "$swap_line" | awk '{print $3}')
  free_swap=$(echo "$swap_line" | awk '{print $4}')

  total_mem_gb=$(awk "BEGIN {printf \"%.2f\", $total_mem/1024}")
  used_mem_gb=$(awk "BEGIN {printf \"%.2f\", $used_mem/1024}")
  free_mem_gb=$(awk "BEGIN {printf \"%.2f\", $free_mem/1024}")

  total_swap_gb=$(awk "BEGIN {printf \"%.2f\", $total_swap/1024}")
  used_swap_gb=$(awk "BEGIN {printf \"%.2f\", $used_swap/1024}")
  free_swap_gb=$(awk "BEGIN {printf \"%.2f\", $free_swap/1024}")

  printf "| Total Memory : %-15s | Used : %-15s | Free : %-15s |\n" "$total_mem_gb GB" "$used_mem_gb GB" "$free_mem_gb GB"
  printf "| Total Swap   : %-16s| Used : %-15s | Free : %-15s |\n" "$total_swap_gb GB" "$used_swap_gb GB" "$free_swap_gb GB"
  echo "+----------------------------------------------------------------------------------+"
}

display_process_monitoring() {
  echo "+----------------------------------------------------------------------------------+"
  echo "| Process Monitoring                                                               |"
  echo "|----------------------------------------------------------------------------------|"
  total_processes=$(ps aux --no-heading | wc -l)
  printf "| Active Processes: %-62s |\n" "$total_processes"
  echo "|----------------------------------------------------------------------------------|"
  echo "| Top 5 Processes by CPU Usage:                                                    |"
  printf "| %-12s | %-27s | %-35s |\n" "PID" "Command" "CPU (%)" 
  echo "|----------------------------------------------------------------------------------|"
  ps -eo pid,comm,%cpu --sort=-%cpu | head -5 | awk '{ printf "| %-12s | %-26s  | %-35s |\n", $1, $2, $3 }'
  echo "|----------------------------------------------------------------------------------|"
  echo "| Top 5 Processes by Memory Usage:                                                 |"
  printf "| %-12s | %-26s | %-36s |\n" "PID" "Command" "MEM (%)"
  echo "|----------------------------------------------------------------------------------|"
  ps -eo pid,comm,%mem --sort=-%mem | head -5 | awk '{ printf "| %-12s | %-26s | %-36s |\n", $1, $2, $3}'
  echo "+----------------------------------------------------------------------------------+"
}

display_service_status() {
  echo "+----------------------------------------------------------------------------------+"
  echo "| Services Status                                                                  |"
  echo "|----------------------------------------------------------------------------------+"
  sshd_status=$(systemctl is-active sshd 2>/dev/null)
  nginx_status=$(systemctl is-active httpd 2>/dev/null)
  iptables_status=$(systemctl is-active iptables 2>/dev/null)

  format_status() {
    if [ "$1" = "active" ]; then
      echo "[RUNNING]"
    else
      echo "[STOPPED]"
    fi
  }

  printf "| sshd: %-17s | nginx: %-17s | iptables: %-17s |\n" \
    "$(format_status "$sshd_status")" "$(format_status "$nginx_status")" "$(format_status "$iptables_status")"
  echo "+----------------------------------------------------------------------------------+"
}
draw_bar() {
  local percent=$1
  local bar=""
  for ((i=0; i<20; i++)); do
    if [ $i -lt $((percent / 5)) ]; then
      bar+="#"
    else
      bar+="-"
    fi
  done
  echo "[$bar]"
}
display_full_dashboard() {
  system_monitor_dashboard
  display_top_processes
  display_network_stats
  display_disk_usage
  display_system_load
  display_memory_usage
  display_process_monitoring
  display_service_status
  echo "+----------------------------------------------------------------------------------+"
  echo "| Press [Q] to exit | Refreshing every 5...                                        |"
  echo "+----------------------------------------------------------------------------------+"
}

# ---------------------- CASE ----------------------

case "$1" in
  -cpu) system_monitor_dashboard ;;
  -memory) display_memory_usage ;;
  -disk) display_disk_usage ;;
  -network) display_network_stats ;;
  -process) display_process_monitoring ;;
  -load) display_system_load ;;
  -services) display_service_status ;;
  -top) display_top_processes ;;
  "" )
    while true; do
      clear
      display_full_dashboard
      read -t 5 -n 1 key
      if [[ "$key" = "q" || "$key" = "Q" ]]; then
        exit 0
      fi
    done
    ;;
  *)
    echo "Usage: $0 [-cpu | -memory | -disk | -network | -process | -load | -services | -top]"
    ;;
esac
