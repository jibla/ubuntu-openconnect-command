#!/bin/bash


# Path variables
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# VPN Variables
IFACE="sslinterface"
VPN_USER="[[your-username]]"
VPN_HOST="[[vpn-host]]"
VPN_PASS='[[your-password]]'
PID="/var/run/openconnect.pid"
TEMP_LOG="/tmp/status.txt"
INFO="

Usage: $(basename "$0") (start|stop|status|restart)

"

# Connect to Cisco SSL VPN using passwords from stdin (passed by VPN_PASS variable created prior)
function connect_vpn(){

if [ -f $PID ]
	then
		printf "\n\tOpenconnect is already running\n"
		exit 1
	else
		echo ${VPN_PASS} | openconnect -b --user=${VPN_USER} --no-dtls ${VPN_HOST} --passwd-on-stdin > $TEMP_LOG 2>&1
		if $(grep -i failed $TEMP_LOG)
			then
				printf "\n\tOpenconnect failed to start!\n"
				cat $TEMP_LOG
				exit 2
			else
				touch $PID
				printf "\n\tOpenconnect started!\n"
		fi
fi
}

# Check if openconnect is running through PID file
function check_openconnect(){

if [ -f $PID ]
	then
		printf "\n\tOpenconnect is running!\n"
	else
		printf "\n\tOpenconnect is stopped\n"
fi
}

# Confirm if PID file exists, then kill it immediately
function kill_openconnect(){

if [ -f $PID ]
	then
		rm -f $PID >/dev/null 2>&1
		kill -9 $(pgrep openconnect) >/dev/null 2>&1
	else
		printf "\n\tOpenconnect is not running!\n"
fi
}

case "$1" in

	start)
	
		connect_vpn
		;;
	
	stop)
	
		kill_openconnect
		;;
	
	status)
	
		check_openconnect
		;;
	
	restart)
	
		$0 stop
		$0 start
		;;
	
	*)
	
		echo "$INFO"
		exit 0
		;;
esac

