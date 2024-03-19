#!/bin/bash

OBSDIR=/marconi/home/userexternal/mdasilva/OBS
wdir=/marconi/home/userexternal/mdasilva/user/mdasilva/EUR-11/obs
cd $wdir

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

obs=EOBS
ys=2000-2001
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
hdir=$OBSDIR/$obs
vars="pr tas"
is=0
for v in $vars; do
  [[ $v = pr  ]] && vc=rr
  [[ $v = tas ]] && vc=tg
  sf=$hdir/${vc}.nc
  echo "## Processing $v $ys "
  mf=${v}_${obs}_${ys}.nc
  CDO -b F32 selyear,$fyr/$lyr -chname,$vc,$v -selvar,$vc $sf $mf
  is=$(( is+1 ))
done
echo "Done."

}
