#!/bin/bash

OBSDIR=/marconi/home/userexternal/ggiulian/esp/ggiulian/OBS
wdir=/marconi_scratch/userexternal/jciarlo0/ERA5/obs
cd $wdir

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

obs=CPC
ys=$1 #1999-1999
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
hdir=$OBSDIR/$obs
vars="pr"
seas="DJF MAM JJA SON"
for v in $vars; do
  [[ $ys = 1970-1979 ]] && continue
  [[ $lyr -le 1979 ]] && continue
  [[ $v = pr ]] && vc=precip
  sf=$hdir/cpc.day.1979-2021.nc
  yf=${v}_${obs}_${ys}.nc
  eval CDO selyear,$fyr/$lyr $sf $yf
  for s in $seas ; do
    echo "## Processing $v $ys $s"
    mf=${v}_${obs}_${ys}_${s}_mean.nc
    CDO timmean -selseas,$s -chname,$vc,$v -selvar,$vc $yf $mf
  done
  rm $yf
done
echo "Done."

}