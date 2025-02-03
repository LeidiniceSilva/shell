#!/bin/bash

OBSDIR=/leonardo_work/ICT24_ESP/OBS
wdir=$2
cd $wdir

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

obs=CPC
hdir=$OBSDIR/$obs
ys=$1
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
vars="pr"
for v in $vars; do
  [[ $fyr -lt 1979 ]] && continue
  [[ $v = pr ]] && vc=precip

  sf=cpc.day.1979-2024.nc
  yf=${v}_${obs}_${ys}.nc
  ff=$( eval ls $hdir/$vc/$vc.????.nc )
  [[ ! -f $sf ]] && CDO mergetime $ff $sf  

  eval CDO chname,$vc,$v -selvar,$vc -selyear,$fyr/$lyr $sf $yf
done
echo "Done."
}
