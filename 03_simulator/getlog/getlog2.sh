#!/bin/sh

today=`date +%y%m%d`
/usr/bin/rcp root@172.30.33.37:/SYSTEM/LOG/msglog/msg$today.log 2_msg$today.log  && echo "2_msg$today.log"

