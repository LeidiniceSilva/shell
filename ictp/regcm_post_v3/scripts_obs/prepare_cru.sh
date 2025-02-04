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

RED='\033[0;31m'
NC='\033[0m' # No Color

if [[ $fyr -lt 1901 || $lyr -lt 1901 || $fyr -gt 2023 || $lyr -gt 2023 ]]; then
  echo -e "${RED}Attention${NC}: $obs from 1901-01 to 2023-12, check input time range."
  exit 1
fi

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
	  ncatted -O -a units,pr,mm/month,c,mm/day $mf
    else
      CDO timmean -selseas,$s -selyear,$fyr/$lyr \
                  -chname,$vc,$v -selvar,$vc $sf $mf
    fi
    is=$(( is+1 ))
  done
done
echo "Done."

}
