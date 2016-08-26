#!/bin/sh
GW=172.30.33.152         #GWのIPアドレスを設定
SHIFT=172.30.32.152      #SHIFTのIPアドレスを設定
USER=root
PASS=pelican
SHIFT_ROOTPASS=dCmepC09
IMSI=440103113600200     #試験で使用するIMSIを設定
DIR=/root/TOOLS/GUT/v0.21 #TOOLを置いてあるディレクトリのPATHを設定

(sleep 1;\
echo $USER;\
sleep 1;\
echo $PASS;\
sleep 1;\
#echo 'str_sgbtrc imsi '$IMSI' > sgbtrc.txt';\
#sleep 3;\
#echo 'scp sgbtrc.txt root@'$SHIFT':'$DIR
#sleep 1;\
#echo $SHIFT_ROOTPASS;\
sleep 1;\
echo 'logout';\
) | telnet $GW

#./gut_set.pl
./gut_set.pl > kekka.txt
cp kekka.txt gut.conf
./gut
