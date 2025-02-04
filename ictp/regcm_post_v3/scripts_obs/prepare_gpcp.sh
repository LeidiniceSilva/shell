#!/bin/bash

OBSDIR=/leonardo/home/userexternal/mdasilva/leonardo_work/OBS
wdir=$2
cd $wdir

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

#
obs=GPCP
hdir=$OBSDIR/$obs/monthly
ys=$1
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )

#
RED='\033[0;31m'
NC='\033[0m' # No Color

#
if [[ $fyr -lt 1983 || $lyr -lt 1983 || $fyr -gt 2021 || $lyr -gt 2021 ]]; then
  echo -e "${RED}Attention${NC}: $obs from 1983-01 to 2022-09, check input time range."
  exit 1
fi

#
vars="pr"
seas="DJF MAM JJA SON"
for v in $vars; do
  [[ $v = pr ]] && vc=sat_gauge_precip

  #sf=GPCPMON_L3_198301-202209_V3.2.nc4
  sf=$hdir/GPCPMON_L3_198301-202209_V3.2.nc4
  yf=${v}_${obs}_${ys}.nc
  #ff=$( eval ls $hdir/GPCPMON_L3_????_V3.2.nc4 )
  #[[ ! -f $sf ]] && CDO mergetime $ff $sf
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
