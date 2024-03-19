#!/bin/bash

OBSDIR=/marconi/home/userexternal/mdasilva/OBS
wdir=/marconi/home/userexternal/mdasilva/user/mdasilva/EUR-11/obs
cd $wdir

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

set -a
obs=GPCC
ys=2000-2001
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
hdir=$OBSDIR/$obs
vars="pr"
seas="DJF MAM JJA SON"
seasdays=( 30.5 30.5 30.5 30.5 )
is=0
for v in $vars; do
  [[ $v = pr ]] && vc=precip
  tf=gpcc.mon.1911-2020.nc
  sf=$( eval ls $OBSDIR/$obs/full_data_monthly_v2022_????_????_025.nc )
  [[ ! -f $tf ]] && CDO mergetime $sf $tf
  yf=${v}_${obs}_${ys}.nc
  eval CDO selyear,$fyr/$lyr $tf $yf
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
