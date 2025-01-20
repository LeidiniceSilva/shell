#!/bin/bash

OBSDIR=/leonardo_work/ICT24_ESP/OBS
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
