#!/bin/bash

OBSDIR=/leonardo/home/userexternal/mdasilva/leonardo_work/OBS
wdir=$2
cd $wdir

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

obs=CRU
hdir=$OBSDIR/$obs
ys=$1
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )

RED='\033[0;31m'
NC='\033[0m' 

if [[ $fyr -lt 1901 || $lyr -lt 1901 || $fyr -gt 2023 || $lyr -gt 2023 ]]; then
  echo -e "${RED}Attention${NC}: $obs from 1901-01 to 2023-12, check input time range."
  exit 1
fi

vars="pr tas"
for v in $vars; do
  [[ $v = pr  ]] && vc=pre
  [[ $v = tas ]] && vc=tmp
  sf=$hdir/${vc}.dat.nc
  echo "## Processing $v $ys"
  mf=${v}_${obs}_${ys}.nc
  if [ $v = pr ]; then
    CDO divc,30.5 -selyear,$fyr/$lyr \
          -chname,$vc,$v -selvar,$vc $sf $mf
  else
    CDO selyear,$fyr/$lyr \
          -chname,$vc,$v -selvar,$vc $sf $mf
  fi
done
echo "Done."

}
