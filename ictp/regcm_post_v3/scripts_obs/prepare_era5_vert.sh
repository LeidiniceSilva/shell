#!/bin/bash

OBSDIR=/leonardo_work/ICT24_ESP/OBS
wdir=$2
cd $wdir

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

set -a
obs=ERA5
hdir=$OBSDIR/$obs/monthly
ys=$1
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
vars="cl cwi clw qh rh"
seas="DJF MAM JJA SON"
seasdays=( 30.5 30.5 30.5 30.5 )
is=0

for v in $vars; do
  [[ $v = cl  ]] && vc=cc && vo=clfrac
  [[ $v = cwi ]] && vc=ciwc && vo=clice
  [[ $v = clw ]] && vc=clwc && vo=clliq
  [[ $v = qh  ]] && vc=q && vo=qhum
  [[ $v = rh  ]] && vc=r && vo=rhum

  for y in `seq ${fyr} ${lyr}`; do
    ff=${v}_${y}.nc
    [[ ! -f $ff ]] && CDO -b f32 mergetime $hdir/$y/${vo}_${y}_*.nc $ff
  done

  yf=${v}_${obs}_${ys}.nc
  ff=$( eval ls ${v}_????.nc )
  CDO -b f32 mergetime $ff $yf
  rm $ff

  for s in $seas ; do
    echo "## Processing $v $ys $s"
    mf=${v}_${obs}_${ys}_${s}_mean.nc
    CDO -timmean -selseas,$s -chname,$vc,$v -selvar,$vc $yf $mf
    is=$(( is+1 ))
  done
  rm $yf
done
echo "Done."

}

