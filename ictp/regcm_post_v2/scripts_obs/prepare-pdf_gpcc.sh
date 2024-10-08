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
obs=GPCC
hdir=$OBSDIR/$obs
ys=$1
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
vars="pr"
for v in $vars; do
  [[ $fyr -lt 1982 ]] && continue
  [[ $v = pr ]] && vc=precip
  tf=gpcc.day.1982-2020.nc
  sf=$( eval ls $OBSDIR/$obs/full_data_daily_v2022_10_????.nc )
  [[ ! -f $tf ]] && CDO mergetime $sf $tf
  yf=${v}_${obs}_${ys}.nc
  eval CDO chname,$vc,$v -selyear,$fyr/$lyr $tf $yf
done
echo "Done."

}
