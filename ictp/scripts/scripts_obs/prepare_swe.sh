#!/bin/bash

OBSDIR=/marconi_work/ICT23_ESP/ggiulian/OBS
wdir=/marconi_scratch/userexternal/jciarlo0/ERA5/obs
cd $wdir

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

obs=SWE
ys=1999-1999
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
hdir=$OBSDIR/${obs}_SNOW

v="snw"
seas="DJF MAM JJA SON"
sf=$( eval ls ${hdir}/SWE_Blended5_1x1daily.{${fyr}..${lyr}}.v2.nc )
of=${v}_${obs}_${ys}.nc

CDO mergetime $sf $of
for s in $seas ; do
  echo "## Processing $v $ys $s"
  mf=${v}_${obs}_${ys}_${s}_mean.nc
  CDO mulc,1000 -timmean -selseas,$s $of $mf
  ncatted -O -a units,$v,m,c,"mm" $mf
done
rm $of
echo "Done."

}
