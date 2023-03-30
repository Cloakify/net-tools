#!/bin/bash
set -x
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
version='1.0'

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Error: ${plain} You must be root！\n" && exit 1

if [ -z $1 ]
then
    echo "${red}Please set the router ip"
    exit 200
fi

#do update and upgrade
#disabling ufw for better performance
apt -y remove needrestart ufw
apt update -yq
apt upgrade -yq
apt install -yq wget curl unzip tar cron git socat nload net-tools

#FixTimeZone
timedatectl set-timezone Asia/Tehran

#enableBBR And IP Forward
echo -e "net.core.default_qdisc=fq\nnet.ipv4.tcp_congestion_control=bbr\nnet.ipv4.ip_forward=1\nnet.ipv6.conf.all.forwarding=1\nnet.ipv4.icmp_echo_ignore_all=1 " >> /etc/sysctl.conf
sysctl -p


#Setting Router Configurations
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination $1:80
iptables -t nat -A PREROUTING -p udp --dport 80 -j DNAT --to-destination $1:80
iptables -t nat -A POSTROUTING -j MASQUERADE

#end debug
set +x

