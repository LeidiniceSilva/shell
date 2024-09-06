#!/bin/bash

OBSDIR=/marconi/home/userexternal/mdasilva/user/mdasilva/OBS
wdir=$2
cd $wdir

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

set -a
obs=ERA5
hdir=$OBSDIR/$obs
ys=$1
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
vars="clt pr tas tasmax tasmin"
seas="DJF MAM JJA SON"
seasdays=( 30.5 30.5 30.5 30.5 )
is=0
for v in $vars; do
  [[ $v = clt     ]] && vc=clt
  [[ $v = pr      ]] && vc=pr
  [[ $v = tas     ]] && vc=tas
  [[ $v = tasmax  ]] && vc=tasmax
  [[ $v = tasmin  ]] && vc=tasmin
  sf=$hdir/${vc}_${obs}_2000-2001.nc
  yf=${v}_${obs}_${ys}.nc
  eval CDO selyear,$fyr/$lyr $sf $yf
  for s in $seas ; do
    echo "## Processing $v $ys $s"
    mf=${v}_${obs}_${ys}_${s}_mean.nc
	if [ $v = pr ]; then # m/day to mm/day
		CDO mulc,1000 -timmean -selseas,$s -selyear,$fyr/$lyr \
			-chname,$vc,$v -selvar,$vc $sf $mf
		ncatted -O -a units,pr,m,c,mm/day $mf
	elif [ $v = clt ]; then # fraction to percentage
		CDO mulc,100 -timmean -selseas,$s -selyear,$fyr/$lyr \
			-chname,$vc,$v -selvar,$vc $sf $mf
		ncatted -O -a units,clt,m,c,% $mf
	else # tas, tasmax, tasmin: K to degree C
		CDO subc,273.15 -timmean -selseas,$s -selyear,$fyr/$lyr \
			-chname,$vc,$v -selvar,$vc $sf $mf
		ncatted -O -a units,$v,m,c,Celsius $mf
	fi
    is=$(( is+1 ))
  done
  rm $yf
done
echo "Done."

}
