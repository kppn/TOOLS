#/bin/bash

start=`grep -n view_fsi $2 | grep start | tail -n 1 | cut -d : -f -1`
end=`grep -n view_fsi $2 | grep end | tail -n 1 | cut -d : -f -1`
echo $start
echo $end

`sed -n $start\,$end\p $2 > $1`
./makechecklog.sh $1

