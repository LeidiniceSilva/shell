#!/bin/bash

OBSDIR=/leonardo_work/ICT24_ESP/OBS
wdir=$2
cd $wdir

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

obs=EOBS
hdir=$OBSDIR/$obs
ys=$1
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
vars="pr tas"
ds1=010
ds2=0.1
is=0
for v in $vars; do
  [[ $v = pr  ]] && vc=rr
  [[ $v = tas ]] && vc=tg
  sf=$hdir/${ds1}/${vc}_ens_mean_${ds2}deg_reg_v30.0e.nc 
  echo "## Processing $v $ys "
  mf=${v}_${obs}_${ys}.nc
  CDO -b F32 selyear,$fyr/$lyr -chname,$vc,$v -selvar,$vc $sf $mf
  is=$(( is+1 ))
done
echo "Done."

}
