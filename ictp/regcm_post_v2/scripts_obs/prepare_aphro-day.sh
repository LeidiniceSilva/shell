#!/bin/bash

OBSDIR=/marconi/home/userexternal/ggiulian/esp/ggiulian/OBS
wdir=/marconi_scratch/userexternal/jciarlo0/ERA5/obs
cd $wdir

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
for v in $vars; do
  [[ $v = pr  ]] && vc=precip
  sf=$( eval ls $hdir/APHRO_MA_025deg_V1101.{1999..2004}.nc )
  yf=${v}_${obs}_${ys}.nc
  [[ ! -f $yf ]] && eval CDO mergetime $sf $yf
  for s in $seas ; do
    echo "## Processing $v $ys $s"
    mf=${v}_${obs}_${ys}_${s}_mean.nc
    CDO selseas,$s -selyear,$fyr/$lyr -chname,$vc,$v -selvar,$vc $yf $mf
  done
done
echo "Done."

}
