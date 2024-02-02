#!/bin/bash

OBSDIR=/marconi/home/userexternal/mdasilva/OBS
wdir=/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/obs
cd $wdir

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

obs=CPC
hdir=$OBSDIR/$obs
ys=2018-2021
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
vars="pr"
for v in $vars; do
  [[ $fyr -lt 1979 ]] && continue
  [[ $lyr -le 1979 ]] && continue
  [[ $v = pr ]] && vc=precip
  sf=$hdir/cpc.day.1979-2021.nc
  yf=${v}_${obs}_${ys}.nc
  eval CDO chname,$vc,$v -selvar,$vc -selyear,$fyr/$lyr $sf $yf
done
echo "Done."
}
