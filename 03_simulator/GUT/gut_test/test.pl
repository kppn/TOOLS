use Socket;


socket(OSOCKET, PF_INET, SOCK_DGRAM, 0);
bind(OSOCKET, pack_sockaddr_in(30000, inet_aton("172.16.1.1")));
$dsock_addr = pack_sockaddr_in(30001, inet_aton("172.16.1.10"));

send(OSOCKET, "hello", 0, $dsock_addr);


