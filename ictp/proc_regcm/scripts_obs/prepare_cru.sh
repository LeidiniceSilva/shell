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
vars="pr tas tasmax tasmin clt"
seas="DJF MAM JJA SON"
seasdays=( 30.5 30.5 30.5 30.5 )
is=0
for v in $vars; do
  [[ $v = pr  ]] && vc=pre
  [[ $v = tas ]] && vc=tmp
  [[ $v = clt ]] && vc=cld
  [[ $v = tasmin ]] && vc=tmn
  [[ $v = tasmax ]] && vc=tmx
  sf=$hdir/${vc}.dat.nc
  for s in $seas ; do
    echo "## Processing $v $ys $s"
    mf=${v}_${obs}_${ys}_${s}_mean.nc
    if [ $v = pr  ]
    then
      CDO divc,${seasdays[$i]} -timmean -selseas,$s -selyear,$fyr/$lyr \
                  -chname,$vc,$v -selvar,$vc $sf $mf
    else
      CDO timmean -selseas,$s -selyear,$fyr/$lyr \
                  -chname,$vc,$v -selvar,$vc $sf $mf
    fi
    is=$(( is+1 ))
  done
done
echo "Done."

}
