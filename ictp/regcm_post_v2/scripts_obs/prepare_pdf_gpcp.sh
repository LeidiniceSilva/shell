#!/bin/bash

OBSDIR=/marconi/home/userexternal/mdasilva/OBS
wdir=/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/obs
cd $wdir

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

obs=GPCP
hdir=$OBSDIR/$obs
ys=2018-2021
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
vars="pr"
for v in $vars; do
  [[ $v = pr  ]] && vc=sat_gauge_precip
  sf=$hdir/GPCPMON_L3_198301-202209_V3.2.nc4
  echo "## Processing $v $ys"
  mf=${v}_${obs}_${ys}.nc
  CDO selyear,$fyr/$lyr \
      -chname,$vc,$v -selvar,$vc $sf $mf
done
echo "Done."

}


