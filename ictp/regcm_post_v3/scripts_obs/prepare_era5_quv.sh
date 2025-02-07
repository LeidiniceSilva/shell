#!/bin/bash

OBSDIR=/leonardo/home/userexternal/mdasilva/leonardo_work/OBS
wdir=$2
cd $wdir

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

set -a
obs=ERA5
hdir=$OBSDIR/$obs
ys=$1
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
vars="hus ua va"

for v in $vars; do
  [[ $v = hus ]] && vc=qhum && vo=q
  [[ $v = ua ]] && vc=uwnd && vo=u
  [[ $v = va ]] && vc=vwnd && vo=v

  yf=${vc}_${obs}_${ys}.nc
  sf=${hdir}/${vo}_ERA5*.nc
  eval CDO chname,$vo,$v -selvar,$vo -selyear,$fyr/$lyr $sf $yf

done
echo "Done."

}

