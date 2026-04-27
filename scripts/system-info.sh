#! /usr/bin/env bash

system_info() {
	echo $(cat /proc/cpuinfo)
	echo $(cat /proc/meminfo)
	echo $(df -h)
	echo $(uptime)
	echo $(who -b)
}

system_info
