#!/bin/bash

OBSDIR=/marconi/home/userexternal/ggiulian/esp/ggiulian/OBS

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

set -a
obs=APHRO
hdir=$OBSDIR/$obs
ys=$1
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
vars="pr"
seas="DJF MAM JJA SON"
seasdays=( 30.5 30.5 30.5 30.5 )
is=0
for v in $vars; do
  [[ $v = pr  ]] && vc=precip
  sf=$hdir/aphro.1999-2004.nc
  yf=${v}_${obs}_${ys}.nc
  eval CDO selyear,$fyr/$lyr $sf $yf
  for s in $seas ; do
    echo "## Processing $v $ys $s"
    mf=${v}_${obs}_${ys}_${s}_mean.nc
	CDO timmean -selseas,$s -selyear,$fyr/$lyr \
		-chname,$vc,$v -selvar,$vc $sf $mf
    is=$(( is+1 ))
  done
  rm $yf
done
echo "Done."

}
