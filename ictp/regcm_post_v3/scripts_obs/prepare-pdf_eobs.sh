#!/bin/bash

OBSDIR=/leonardo/home/userexternal/mdasilva/leonardo_work/OBS
wdir=$2
cd $wdir

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

obs=EOBS
ds1=010
ds2=0.1
ys=$1
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
hdir=$OBSDIR/$obs/${ds1}

RED='\033[0;31m'
NC='\033[0m' # No Color

if [[ $fyr -lt 1950 || $lyr -lt 1950 || $fyr -gt 2023 || $lyr -gt 2023 ]]; then
  echo -e "${RED}Attention${NC}: $obs from 1950-01-01 to 2024-06-30, check input time range."
  exit 1
fi

vars="pr tas"
for v in $vars; do
  [[ $v = pr  ]] && vc=rr
  [[ $v = tas ]] && vc=tg
  sf=$hdir/${vc}_ens_mean_${ds2}deg_reg_v30.0e.nc 
  echo "## Processing $v $ys "
  mf=${v}_${obs}_${ys}.nc
  CDO -b F32 selyear,$fyr/$lyr -chname,$vc,$v -selvar,$vc $sf $mf
done
echo "Done."

}
