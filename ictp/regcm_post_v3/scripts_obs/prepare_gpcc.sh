#!/bin/bash

OBSDIR=OBSDIR=/leonardo/home/userexternal/mdasilva/leonardo_work/OBS
wdir=$2
cd $wdir

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

obs=GPCC
hdir=$OBSDIR/$obs
ys=$1
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )

RED='\033[0;31m'
NC='\033[0m' 

if [[ $fyr -lt 1891 || $lyr -lt 1891 || $fyr -gt 2020 || $lyr -gt 2020 ]]; then
  echo -e "${RED}Attention${NC}: $obs from 1891-01 to 2020-12, check input time range."
  exit 1 
fi

vars="pr"
seas="DJF MAM JJA SON"
seasdays=( 30.5 30.5 30.5 30.5 )
is=0
for v in $vars; do
  [[ $v = pr ]] && vc=precip
  sf=$hdir/precip.gpcc.mon.1891.2020.nc
  yf=${v}_${obs}_${ys}.nc
  eval CDO selyear,$fyr/$lyr $sf $yf
  for s in $seas ; do
    echo "## Processing $v $ys $s"
    mf=${v}_${obs}_${ys}_${s}_mean.nc
    if [ $v = pr  ]
    then
      CDO divc,${seasdays[$i]} -timmean -selseas,$s \
                  -chname,$vc,$v -selvar,$vc $yf $mf
	  ncatted -O -a units,pr,mm/month,c,mm/day $mf
    else
      CDO timmean -selseas,$s \
                  -chname,$vc,$v -selvar,$vc $yf $mf
    fi
    is=$(( is+1 ))
  done
  rm $yf
done
echo "Done."

}
