#!/bin/bash

# OBSDIR=/leonardo_work/ICT24_ESP/OBS
OBSDIR=/leonardo_work/ICT24_ESP/clu/OBS
wdir=$2
cd $wdir

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

set -a

#
obs=ERA5
hdir=$OBSDIR/$obs/monthly
ys=$1
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )

#
RED='\033[0;31m'
NC='\033[0m' # No Color

if [[ $fyr -lt 1950 || $lyr -lt 1950 || $fyr -gt 2023 || $lyr -gt 2023 ]]; then
  echo -e "${RED}Attention${NC}: $obs from 1950-01 to 2023-12, check input time range."
  exit 1 
fi

#
vars="clt pr tas"
seas="DJF MAM JJA SON"
seasdays=( 30.5 30.5 30.5 30.5 )
is=0

for v in $vars; do
  [[ $v = clt     ]] && vc=tcc
  [[ $v = pr      ]] && vc=tp
  [[ $v = tas     ]] && vc=t2m

#  for y in `seq ${fyr} ${lyr}`; do
#    ff=${v}_${y}.nc
#    [[ ! -f $ff ]] && CDO -b f32 mergetime $hdir/$y/${v}_${y}_*.nc $ff
#  done
#
#  yf=${v}_${obs}_${ys}.nc
#  ff=$( eval ls ${v}_????.nc )
#  CDO -b f32 mergetime $ff $yf
#  rm $ff
  yf=$hdir/${v}.era5.mon.1950-2023.nc

  for s in $seas ; do
    echo "## Processing $v $ys $s"
    mf=${v}_${obs}_${ys}_${s}_mean.nc
	if [ $v = pr ]; then # m/day to mm/day
		CDO mulc,1000 -timmean -selseas,$s -selyear,$fyr/$lyr \
			-chname,$vc,$v -selvar,$vc $yf $mf
		ncatted -O -a units,pr,m,c,mm/day $mf
	elif [ $v = clt ]; then # fraction to percentage
		CDO mulc,100 -timmean -selseas,$s -selyear,$fyr/$lyr \
			-chname,$vc,$v -selvar,$vc $yf $mf
		ncatted -O -a units,clt,m,c,% $mf
	else # tas: K to degree C
		CDO subc,273.15 -timmean -selseas,$s -selyear,$fyr/$lyr \
			-chname,$vc,$v -selvar,$vc $yf $mf
		ncatted -O -a units,$v,m,c,Celsius $mf
	fi
    is=$(( is+1 ))
  done
  # rm $yf
done
echo "Done."

}
