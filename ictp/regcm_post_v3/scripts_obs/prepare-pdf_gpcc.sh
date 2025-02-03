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

#
obs=GPCC
hdir=$OBSDIR/$obs
ys=$1
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )

#
RED='\033[0;31m'
NC='\033[0m' # No Color

if [[ $fyr -lt 1982 || $lyr -lt 1982 || $fyr -gt 2020 || $lyr -gt 2020 ]]; then
  echo -e "${RED}Attention${NC}: $obs from 1982-01-01 to 2020-12-31, check input time range."
  exit 1 
fi

#
vars="pr"
for v in $vars; do
  [[ $v = pr ]] && vc=precip
  sf=$hdir/precip.gpcc.1982.2020.nc
  yf=${v}_${obs}_${ys}.nc
  eval CDO chname,$vc,$v -selvar,$vc -selyear,$fyr/$lyr $sf $yf
done
echo "Done."
}
