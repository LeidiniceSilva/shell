#!/bin/bash

# OBSDIR=/leonardo_work/ICT24_ESP/OBS
OBSDIR=/leonardo_work/ICT24_ESP/clu/OBS
wdir=$2
cd $wdir

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

#
obs=CPC
hdir=$OBSDIR/$obs/precip
ys=$1
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )

#
RED='\033[0;31m'
NC='\033[0m' # No Color

if [[ $fyr -lt 1979 || $lyr -lt 1979 || $fyr -gt 2024 || $lyr -gt 2024 ]]; then
  echo -e "${RED}Attention${NC}: $obs from 1979-01-01 to 2024-12-31, check input time range."
  exit 1 
fi

#
vars="pr"
seas="DJF MAM JJA SON"
for v in $vars; do
  #[[ $ys = 2000-2009 ]] && continue
  #[[ $fyr -lt 1979 ]] && continue
  #[[ $lyr -le 1979 ]] && continue
  [[ $v = pr ]] && vc=precip
  sf=$hdir/precip.cpc.1979.2024.nc
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
