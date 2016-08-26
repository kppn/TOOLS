#!/bin/sh
mkdir $1file
./diameter_sigget.sh $1 $2
./sig $1
mv $1* $1file
