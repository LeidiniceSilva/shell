#!/bin/bash

OBSDIR=/marconi/home/userexternal/mdasilva/user/mdasilva/OBS
wdir=$2
cd $wdir

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

set -a
obs=MSWEP
hdir=$OBSDIR/$obs
ys=$1
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
vars="pr"
is=0
for v in $vars; do
  [[ $fyr -lt 1979 ]] && continue
  [[ $v = pr ]] && vc=precipitation
  sf=$hdir/mswep.mon.1979-2020.nc
    echo "## Processing $v $ys "
    mf=${v}_${obs}_${ys}.nc
    eval CDO divc,30.5 -selyear,$fyr/$lyr -chname,$vc,$v -selvar,$vc $sf $mf
    ncatted -O -a units,pr,m,c,mm/day $mf
    is=$(( is+1 ))
done
echo "Done."

}
