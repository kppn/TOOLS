#!/usr/bin/python
# -*- coding:utf-8 -*-
import sys
import socket
import binascii
import struct
import time

# Debug
DBG = 1 # 0:off
        # 1:debug level Low
        # 2:debug level Middlle
        # 3:debug level High

# define value
port = 7
flowinfo = 0
scopeid = 1
msg = "wake up"

# input value
if DBG == 3:
    host = '2002:502::4410:1035:3100:0'
    count = 10
    bhca = 3600
else:
    argvs = sys.argv
    argc = len(argvs)
    host = argvs[1]
    count = int(argvs[2])
    bhca = int(argvs[3])


def divideIpv6(host):
    if DBG>=2: print"Call : divideIpv6"
    binIpadr6 = socket.inet_pton(socket.AF_INET6,host)
    asciiIpadr6Base =  "%s" % binascii.b2a_hex(binIpadr6)
    asciiIpadr6Edit = asciiIpadr6Base[28:]

    if DBG>=2: print "divideIpv6:host = %s" %host
    if DBG>=2: print "divideIpv6:asciiIpadr6Base = %s" % asciiIpadr6Base
    if DBG>=2: print "divideIpv6:asciiIpadr6Edit = %s" % asciiIpadr6Edit
    return asciiIpadr6Base, asciiIpadr6Edit


def sendUdp(host):
    if DBG>=2: print"Call : sendUdp"
    s = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
    try :
        s.connect((host,port,flowinfo, scopeid))
        s.sendall(msg)
        s.close()
        if DBG>=1 : print "targetIpAdr6 = %s" % host
    except socket.error :
        if DBG>=1 : print "send err : %s" % host
        pass

    time.sleep(sleepTime)
    return

def bhcaSleepTime(bhca):
    if DBG>=2: print"Call : bhcaSleepTime"
    sleepTime = 3600 / float(bhca)
    return sleepTime

def increaseIpAddr(asciiIpadr6Edit):
    if DBG>=2: print"Call : increaseIpAddr"
    tmpAsciiIpadr6Edit = int(asciiIpadr6Edit,16)
    tmpAsciiIpadr6Edit += 1
    asciiIpadr6Edit = "%04x" % tmpAsciiIpadr6Edit
    if DBG>=2: print "increaseIpAddr:asciiIpadr6Edit = %s" % asciiIpadr6Edit
    return asciiIpadr6Edit


# main ------------------------------------------------------------
asciiIpadr6Base, asciiIpadr6Edit = divideIpv6(host)
if DBG>=2: print "main:asciiIpadr6Base = %s" % asciiIpadr6Base
if DBG>=2: print "main:asciiIpadr6Edit = %s" % asciiIpadr6Edit
sleepTime = bhcaSleepTime(bhca)
saveAsciiIpadr6Edit = asciiIpadr6Edit
saveCount = count

while 1:
    targetIpAdr6 = asciiIpadr6Base[0:4]+":"+asciiIpadr6Base[4:8]+":"+asciiIpadr6Base[8:12]+":"+asciiIpadr6Edit[:]+":"+asciiIpadr6Base[16:20]+":"+asciiIpadr6Base[20:24]+":"+asciiIpadr6Base[24:28]+":"+asciiIpadr6Edit[:]
    if DBG>=2: print "main:targetIpAdr6 = %s" % targetIpAdr6
    sendUdp(targetIpAdr6)

    # increase IP Address
    asciiIpadr6Edit = increaseIpAddr(asciiIpadr6Edit)

    # Count
    count -= 1
    if count == 0:
        asciiIpadr6Edit = saveAsciiIpadr6Edit
        count = saveCount
