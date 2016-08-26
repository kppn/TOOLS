#!/bin/sh



function iptabiles_pad_add(){
iptables -A INPUT -d 192.168.210.70 -p udp --dport 32247 -j ACCEPT
iptables -A INPUT -d 192.168.210.66 -p udp --dport 32247 -j DROP
iptables -L -v
}


function iptables_pad_del(){
iptables -D INPUT -d 192.168.210.70 -p udp --dport 32247 -j ACCEPT
iptables -D INPUT -d 192.168.210.66 -p udp --dport 32247 -j DROP
iptables -L -v
}

function iptabiles_pacd_add(){
iptables -A INPUT -d 192.168.210.70 -p udp --dport 32248 -j ACCEPT
iptables -A INPUT -d 192.168.210.66 -p udp --dport 32248 -j DROP
iptables -L -v
}


function iptables_pacd_del(){
iptables -D INPUT -d 192.168.210.70 -p udp --dport 32248 -j ACCEPT
iptables -D INPUT -d 192.168.210.66 -p udp --dport 32248 -j DROP
iptables -L -v
}

function iptabiles_pad2_add(){
iptables -A INPUT -d 192.168.210.70 -p udp --dport 32247 -j DROP
iptables -A INPUT -d 192.168.210.66 -p udp --dport 32247 -j DROP
iptables -L -v
}


function iptables_pad2_del(){
iptables -D INPUT -d 192.168.210.70 -p udp --dport 32247 -j DROP
iptables -D INPUT -d 192.168.210.66 -p udp --dport 32247 -j DROP
iptables -L -v
}

function iptabiles_pacd2_add(){
iptables -A INPUT -d 192.168.210.70 -p udp --dport 32248 -j DROP
iptables -A INPUT -d 192.168.210.66 -p udp --dport 32248 -j DROP
iptables -L -v
}

function iptables_pacd2_del(){
iptables -D INPUT -d 192.168.210.70 -p udp --dport 32248 -j DROP
iptables -D INPUT -d 192.168.210.66 -p udp --dport 32248 -j DROP
iptables -L -v
}

case $1 in 
	"pad_set") iptabiles_pad_add;;
	"pad_del") iptables_pad_del;;
	"pacd_set") iptabiles_pacd_add;;
	"pacd_del") iptables_pacd_del;;
 
	"pad2_set") iptabiles_pad2_add;;
	"pad2_del") iptables_pad2_del;;
	"pacd2_set") iptabiles_pacd2_add;;
	"pacd2_del") iptables_pacd2_del;; 
esac

