#!/bin/bash

# Path variables
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# VPN Variables

VPN_HOST='host'
VPN_USER='username'
VPN_PASS='password'
VPN_CERT='' # if not needed leave it as empty string

IFACE='sslinterface'
PID='/var/run/openconnect.pid'
TEMP_LOG='/tmp/vpn_status.txt'
INFO="
Usage: $(basename "$0") (start|stop|status|restart)
"

# Connect to Cisco SSL VPN using passwords from stdin (passed by VPN_PASS variable created prior)
function connect_vpn() { 

    if [ -s $PID ]
        then
            printf "Openconnect is already running\n"
            exit 1
        else

            # checking if ssl certificate is provided
			if [ -z $VPN_CERT ] 
                then
				    CERT=''
			    else
				    CERT="--servercert $VPN_CERT"
			fi

            echo ${VPN_PASS} | openconnect ${VPN_HOST} --user=${VPN_USER} ${CERT} -b --no-dtls --passwd-on-stdin --pid-file $PID > $TEMP_LOG 2>&1
            if $(grep -iq "connected as" $TEMP_LOG)
                then
                    touch $PID
                    printf "Openconnect started!\n"
                else
                    printf "Openconnect failed to start!\n"
                    cat $TEMP_LOG
                    exit 2
            fi
    fi
}

# Check if openconnect is running through PID file
function check_openconnect() {

    if [ -s $PID ]
        then
            printf "Openconnect is running!\n"
        else
            printf "Openconnect is stopped\n"
    fi
}

# Confirm if PID file exists, then kill it immediately
function kill_openconnect() {

    if [ -s $PID ]
        then
            rm -f $PID > /dev/null 2>&1
            kill -9 $(pgrep openconnect) > /dev/null 2>&1
        else
            printf "Openconnect is not running!\n"
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
