ifconfig tun0 192.168.0.1/24 pointopoint 192.168.1.1
route add -net 10.0.0.0/8 dev tun0
#
#ip addr add 2001::1/64 dev tun0
#route -A inet6 add 2002::/64 dev tun0

