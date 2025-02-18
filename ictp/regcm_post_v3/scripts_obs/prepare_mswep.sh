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

RED='\033[0;31m'
NC='\033[0m' 

if [[ $fyr -lt 1980 || $lyr -lt 1980 || $fyr -gt 2019 || $lyr -gt 2019 ]]; then
  echo -e "${RED}Attention${NC}: $obs from 1979-02-01 to 2020-11-30, check input time range."
  exit 1 
fi

vars="pr"
seas="DJF MAM JJA SON"
seasdays=( 30.5 30.5 30.5 30.5 )
is=0
for v in $vars; do
  [[ $fyr -lt 1979 ]] && continue
  [[ $v = pr ]] && vc=precipitation

  sf=$hdir/mswep.mon.1979-2020.nc
  yf=${v}_${obs}_${ys}.nc 
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
