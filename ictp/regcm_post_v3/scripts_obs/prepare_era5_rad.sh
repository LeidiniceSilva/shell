#!/bin/bash

OBSDIR=/marconi/home/userexternal/mdasilva/OBS
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
vars="rsnl"
seas="DJF MAM JJA SON"
seasdays=( 30.5 30.5 30.5 30.5 )
is=0
for v in $vars; do
  echo "##### Processing $v"
  [[ $v = rsnl    ]] && vc=msnlwrf
  sf=$hdir/${vc}_${obs}_2000-2001.nc
  yf=${v}_${obs}_${ys}.nc
  eval CDO selyear,$fyr/$lyr $sf $yf
  for s in $seas ; do
    echo "## Processing $v $ys $s"
    mf=${v}_${obs}_${ys}_${s}_mean.nc
	CDO -b f32 mulc,-1 -timmean -selseas,$s -selyear,$fyr/$lyr \
		-chname,$vc,$v -selvar,$vc $sf $mf
    is=$(( is+1 ))
  done
  rm $yf
done
echo "Done."
}
