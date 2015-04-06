#!/bin/bash
#===============================================================================
#          FILE: configure_firewall.sh
#         USAGE: ./configure_firewall.sh
#   DESCRIPTION: opens ports in firewall for normal operation of kaltura streaming server
#       OPTIONS: ---
#       LICENSE: AGPLv3+
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Igor Shevach <igor.shevach@kaltura.com>
#  ORGANIZATION: Kaltura, inc.
#       CREATED: 22/02/15 09:23:34 EST
#      REVISION:  ---
#===============================================================================
. $(dirname $0)/utils/*

configure_port()
{
	echo "opening port $1"

        local rule_exists=$(iptables -S INPUT | grep -e "-A" |  awk  "/-p tcp/ && /--dport $1/ && /-j ACCEPT/")

        while [[ -n  $rule_exists ]]
        do
                sudo iptables -D INPUT -p tcp --dport $1 -j ACCEPT
                rule_exists=$(sudo iptables -S INPUT | grep -e "-A" | awk  "/-p tcp/ && /--dport $1/ && /-j ACCEPT/")
        done
        sudo iptables -I INPUT 1 -p 'tcp' --dport $1 -j ACCEPT || _S "open port $1"

}

configure_firewall()
{
        configure_port 8088
        configure_port 1935

        sudo chkconfig iptables on

        sudo service iptables save

        sudo /etc/init.d/WowzaStreamingEngine stop >> /dev/null 2>&1

        sudo /etc/init.d/WowzaStreamingEngine start

}

configure_firewall
