#!/bin/bash

GWU_IP=$1
COMMAND="$2 $3 $4 $5 $6"


expect -c "
set timeout 20
spawn telnet $GWU_IP

expect login:
send \"root\n\"

expect Password:
send \"root123\n\"

expect router
send \"$COMMAND\n\"

expect router
send \"exit\n\"
"



