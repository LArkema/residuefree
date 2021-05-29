#!/bin/bash

NAME="test"
RVETH="resveth0"
HVETH="hostveth0"
SUBNET="10.0.1"

#Create new network namespace (netns) connected by virtual ethernet (veth) pair
ip netns add $NAME
ip link add $RVETH type veth peer name $HVETH
ip link set $RVETH netns $NAME

#Add IP addresses in SUBNET network (default 10.0.1.0/24)
ip netns exec $NAME ip addr add $SUBNET.2/24 dev $RVETH
ip addr add $SUBNET.1/24 dev $HVETH

#Set veth connections up
ip netns exec $NAME ip link set $RVETH up
ip link set $HVETH up

#Add default routing to residue free namespace
ip netns exec $NAME ip route add default via $SUBNET.1 dev $RVETH

#Add NAT post-routing to ip tables.
iptables -t nat -A POSTROUTING -s $SUBNET.0/24 -j MASQUERADE

#Enable ipv4 ip forwarding
sysctl -w net.ipv4.ip_forward=1

#Add DNS Server to resolv.conf
ip netns exec $NAME sed -i "/nameserver 127.0.0.53/i nameserver 9.9.9.9" /etc/resolv.conf

#Run bash shell in namespace
ip netns exec $NAME bash

#Remove devices, namespace, and iptables configurations
ip netns del $NAME
ip link del dev $HVETH
iptables -t nat -D POSTROUTING -s $SUBNET.0/24 -j MASQUERADE

