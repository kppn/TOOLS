#!/bin/sh
GW=172.30.33.138         #GWのIPアドレスを設定
SHIFT=172.30.32.151      #SHIFTのIPアドレスを設定
USER=root
PASS=pelican
SHIFT_ROOTPASS=dCmepC09
IMSI=440101540040304     #試験で使用するIMSIを設定
DIR=/root/TOOLS/GUT/v0.23/S5-GTP/gijiM #TOOLを置いてあるディレクトリのPATHを設定

(sleep 1;\
echo $USER;\
sleep 1;\
echo $PASS;\
sleep 1;\
echo 'str_sgbtrc imsi '$IMSI' > sgbtrc.txt';\
sleep 3;\
echo 'scp sgbtrc.txt root@'$SHIFT':'$DIR
sleep 1;\
echo $SHIFT_ROOTPASS;\
sleep 1;\
echo 'logout';\
) | telnet $GW

#./gut_set.pl
./gut_set.pl > kekka.txt
cp -f kekka.txt gut.conf
../../gut
