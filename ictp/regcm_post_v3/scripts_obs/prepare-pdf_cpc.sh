#!/bin/bash

#OBSDIR=/leonardo_work/ICT24_ESP/OBS
OBSDIR=/leonardo_work/ICT24_ESP/clu/OBS
wdir=$2
cd $wdir

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

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
for v in $vars; do
  #[[ $fyr -lt 1991 ]] && continue
  #[[ $lyr -le 1991 ]] && continue
  [[ $v = pr ]] && vc=precip
  #sf=$hdir/$vc/cpc.day.1991-2020.nc
  sf=$hdir/precip.cpc.1979.2024.nc
  yf=${v}_${obs}_${ys}.nc
  eval CDO chname,$vc,$v -selvar,$vc -selyear,$fyr/$lyr $sf $yf
done
echo "Done."
}
