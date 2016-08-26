#!/bin/sh

today=`date +%y%m%d`
/usr/bin/rcp root@172.30.33.47:/SYSTEM/LOG/msglog/msg$today.log . && echo "msg$today.log"

