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
ys=$1
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
hdir=$OBSDIR/$obs
vars="pr tas tasmax tasmin"
seas="DJF MAM JJA SON"
ds1=010
ds2=0.1
is=0
for v in $vars; do
  [[ $v = pr  ]] && vc=rr
  [[ $v = tas ]] && vc=tg
  [[ $v = tasmin ]] && vc=tn
  [[ $v = tasmax ]] && vc=tx
  sf=$hdir/${ds1}/${vc}_ens_mean_${ds2}deg_reg_v30.0e.nc 
  for s in $seas ; do
    echo "## Processing $v $ys $s"
    mf=${v}_${obs}_${ys}_${s}_mean.nc
    CDO timmean -selseas,$s -selyear,$fyr/$lyr \
                -chname,$vc,$v -selvar,$vc $sf $mf
    is=$(( is+1 ))
  done
done
echo "Done."

}
