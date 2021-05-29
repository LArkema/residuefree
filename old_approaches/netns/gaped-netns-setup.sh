#!/bin/bash

#This script must be ran as root

NAME="test"
IP=$(hostname -I | cut -d' ' -f1)
GATEWAY=$(/sbin/ip route | awk '/default/ {print $3}')
DEV=$(/sbin/ip link show | grep ^[2-9][0-9]* | cut -d':' -f2)

ip netns add $NAME
ip link set dev enp0s3 netns $NAME
ip netns exec $NAME ip addr add $IP/24 dev $DEV
ip netns exec $NAME ip link set lo up
ip netns exec $NAME ip link set $DEV up
ip netns exec $NAME ip route add default via $GATEWAY
ip netns exec $NAME sed -i "/nameserver 127.0.0.53/i nameserver 9.9.9.9" /etc/resolv.conf

#Filter out connections to localhost
#ip netns exec $NAME iptables -A OUTPUT -d localhost -p all -j DROP
#ip netns exec $NAME iptables -A OUTPUT -d $IP -p all -j DROP

#run bash shell
ip netns exec $NAME bash
ip netns exec $NAME ip link set dev $DEV netns 1
ip netns del $NAME
