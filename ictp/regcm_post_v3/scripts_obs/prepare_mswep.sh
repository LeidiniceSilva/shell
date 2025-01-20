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
obs=MSWEP
hdir=$OBSDIR/$obs/monthly
ys=$1
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
vars="pr"
seas="DJF MAM JJA SON"
seasdays=( 30.5 30.5 30.5 30.5 )
is=0
for v in $vars; do
  [[ $fyr -lt 1979 ]] && continue
  [[ $v = pr ]] && vc=precipitation

  sf=mswep.mon.1979-2020.nc
  yf=${v}_${obs}_${ys}.nc
  ff=$( eval ls ??????.nc )
  [[ ! -f $sf ]] && CDO mergetime $ff $sf  
  eval CDO selyear,$fyr/$lyr $sf $yf

  for s in $seas ; do
    echo "## Processing $v $ys $s"
    mf=${v}_${obs}_${ys}_${s}_mean.nc
    CDO divc,${seasdays[$i]} -timmean -selseas,$s \
        -chname,$vc,$v -selvar,$vc $yf $mf
    ncatted -O -a units,pr,m,c,mm/day $mf
    is=$(( is+1 ))
  done
  rm $yf
done
echo "Done."

}
