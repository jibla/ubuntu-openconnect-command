#!/bin/bash

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
PID='/var/run/vpn.pid'
LOG_PATH='/tmp/vpn_status.txt'
INFO="Usage: $(basename "$0") (start|stop|status|restart)"

# format: 'host username password cert'. cert (certificate) is not mandatory
CREDENTIALS=(
    'host1 username1 password1 cert1'
    'host2 username2 password2'
    'host3 username3 password3 cert3'
)


function start() { 

    if ! is_network_available
        then 
            printf "Network is not available. Check your internet connection \n"
            exit 1
    fi

    if is_vpn_running
        then
            printf "VPN is already running\n"
            exit 1
    fi

    for item in "${CREDENTIALS[@]}"; do 

        local credentials=($item)
        local host=${credentials[0]}
        local username=${credentials[1]}
        local password=${credentials[2]}
        local cert=${credentials[3]}

        echo "Connecting to $host"

        connect $host $username $password $cert

        if is_vpn_running
            then 
                printf "VPN is connected \n"
                print_current_ip_address
                break
            else
                printf "VPN failed to connect! \n"
        fi
    done
}

function connect() {
    cert=$(get_cert_if_provided $4)
    echo $3 | openconnect $1 --user=$2 ${cert} -b --no-dtls --passwd-on-stdin --pid-file $PID > $LOG_PATH 2>&1
}

function status() {

    if is_vpn_running
        then
            printf "VPN is running \n"
        else
            printf "VPN is stopped \n"
    fi
}

function stop() {

    if is_vpn_running
        then
            rm -f $PID > /dev/null 2>&1
            kill -9 $(pgrep openconnect) > /dev/null 2>&1
    fi
    
    printf "VPN is disconnected \n"
    print_current_ip_address
}

function is_network_available() {
    ping -q -c 1 -W 1 8.8.8.8 > /dev/null 2>&1;
}

function is_vpn_running() {
    test -s $PID 
}

function print_current_ip_address() {
    local NEW_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
    printf "Your IP address is $NEW_IP \n"
}

function get_cert_if_provided() {
    test -z $1 && echo '' || echo "--servercert $1"
}

case "$1" in

	start)
	
		start
		;;
	
	stop)
	
		stop
		;;
	
	status)
	
		status
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