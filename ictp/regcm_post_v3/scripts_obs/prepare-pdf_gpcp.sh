#!/bin/bash

OBSDIR=/leonardo_work/ICT24_ESP/OBS
wdir=$2
cd $wdir

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

obs=GPCP
hdir=$OBSDIR/$obs/daily
ys=$1
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
vars="pr"
for v in $vars; do
  [[ $v = pr  ]] && vc=sat_gauge_precip

  sf=GPCPDAY_L3_200006-202109_V3.2.nc4
  ff=$( eval ls GPCPDAY_L3_????_V3.2.nc4 )
  [[ ! -f $sf ]] && CDO mergetime $ff $sf

  echo "## Processing $v $ys"
  mf=${v}_${obs}_${ys}.nc
  CDO selyear,$fyr/$lyr \
      -chname,$vc,$v -selvar,$vc $sf $mf
done
echo "Done."

}


