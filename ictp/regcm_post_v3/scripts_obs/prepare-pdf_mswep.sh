#!/bin/bash

OBSDIR=/leonardo_work/ICT24_ESP/OBS
wdir=$2
cd $wdir

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

set -a
obs=MSWEP
hdir=$OBSDIR/$obs/daily
ys=$1
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
vars="pr"
is=0
for v in $vars; do
  [[ $fyr -lt 1979 ]] && continue
  [[ $v = pr ]] && vc=precipitation

  sf=mswep.day.1979-2020.nc
  ff=$( eval ls ????.nc )
  [[ ! -f $sf ]] && CDO mergetime $ff $sf  

  echo "## Processing $v $ys "
  mf=${v}_${obs}_${ys}.nc
  eval CDO chname,$vc,$v -selvar,$vc -selyear,$fyr/$lyr $sf $yf
  ncatted -O -a units,pr,m,c,mm/day $mf
  is=$(( is+1 ))
done
echo "Done."

}
