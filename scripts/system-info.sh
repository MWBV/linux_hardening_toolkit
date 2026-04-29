#!/usr/bin/env bash

### This function output the basic system information

set -euo pipefail

#### Helper Functions ####
title() {
	echo -e "\n--- $1 ---"
}
row() {
	printf "%-15s %s\n" "$1 $2"
}
system_info() {
	##### HOST INFORMATION #####
	title "System Information"
	row "Hostname:" "$(hostname)"
	row "OS:" "$(grep 'PRETTY_NAME' /etc/os-release | cut -d '=' -f2 | tr -d '"')"
	row "Kernel:" "$(uname -r)"
	row "Uptime:" "$(uptime -p)"
	row "Last Boot:" "$(who -b | awk '{print $3, $4}')"

	##### CPU #####
	title "CPU Information"
	row "Model:" "$(lscpu | grep 'Model name' | awk -F: '{print $2}' | xargs)"
	row "Cores:" "$(lscpu | grep '^CPU(s):' | awk -F: '{print $2}' | xargs)"
	row "Architecture:" "$(lscpu | grep 'Arichitecture' | awk -F: '{print $2}' | xargs)"

	##### Memory #####
	title "Memory Information"
	row "Total:" "$(grep 'MemTotal' /proc/meminfo | awk '{print $2/1024/1024 " GB"}')"
	row "Free:" "$(grep 'MemFree' /proc/meminfo | awk '{print $2/1024/1024 " GB"}')"
	row "Used:" "$(grep 'MemAvailable' /proc/meminfo | awk '{print $2/1024/1024 " GB"}')"

	##### Disk Usage #####
	title "Disk Usage"
	df -h --output=source,fstype,size,used,avail,pcent,target | grep -v tmpfs

	#### Active Users #####
	title "Active Users"
	who | awk '{print $1 ,$2, $3}'
}

system_info
