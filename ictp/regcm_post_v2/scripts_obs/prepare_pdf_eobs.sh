#!/bin/bash

OBSDIR=/marconi_work/ICT23_ESP/jciarlo0/obs/eobs
wdir=/marconi_scratch/userexternal/jciarlo0/ERA5/obs
cd $wdir

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

obs=EOBS
ys=$1 #1999-1999
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
hdir=$OBSDIR
vars="pr tas"
is=0
for v in $vars; do
  [[ $v = pr  ]] && vc=rr
  [[ $v = tas ]] && vc=tg
  sf=$hdir/${vc}_*.nc
  echo "## Processing $v $ys "
  mf=${v}_${obs}_${ys}.nc
  CDO -b F32 selyear,$fyr/$lyr -chname,$vc,$v -selvar,$vc $sf $mf
  is=$(( is+1 ))
done
echo "Done."

}
