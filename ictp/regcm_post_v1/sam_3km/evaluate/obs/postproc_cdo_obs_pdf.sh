#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the OBS datasets with CDO'

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

CDOf(){
  CDO -b F32 $@
}

cpdf(){
  mn=$1 ; mx=$2 ; fin=$3 ; fout=$4
  CDOf fldsum -timsum -gec,-1000 $fin ${fout}_cnt.nc
  vv=$( basename $fin | cut -d'_' -f1 )
  set +e 
  nc=$( ncdump -v $vv ${fout}_cnt.nc | tail -2 | head -1 | cut -d' ' -f3 )
  set -e
  CDOf divc,$nc -fldsum -histcount,$( echo $( seq $mn 1 $mx ) | sed 's/ /,/g' ) $fin $fout
  rm ${fout}_cnt.nc
}

fminmax(){
  f=$1 ; xf=$2 ; mnmx=$3
  CDO fld${mnmx} -tim${mnmx} $f $xf >/dev/null 2>/dev/null
  nx=$( ncdump -v $VAR $xf | tail -2 | head -1 | cut -d' ' -f3 )
  /usr/bin/printf '%.*f\n' 0 $nx
  rm $xf
} 

YR="2018-2021"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

DATASET="CPC"
EXP="SAM-3km"

DIR_IN="/marconi/home/userexternal/mdasilva/OBS"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_evaluate/obs"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

if [ ${DATASET} == 'CPC' ]
then
echo 
echo "------------------------------- PROCCESSING CPC DATASET -------------------------------"

VAR="precip"

echo
echo "1.1. Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cpc.day.1979-2021.nc ${VAR}_${EXP}_${DATASET}_${YR}.nc
  
echo
echo "1.1. Define files"
obsvsb=${VAR}_${EXP}_${DATASET}_${YR}.nc
obsvout=${VAR}_${DOMAIN}_${DATASET}_day_${YR}_pdf.nc

echo
echo "1.2. Calculate min and max"
maxf=${VAR}_max.nc
maxt=${VAR}_max.txt
mxo=$( fminmax $obsvsb $maxf "max" )
mxA=$mxo
echo $mxA > $maxt

minf=${VAR}_min.nc
mint=${VAR}_min.txt
mno=$( fminmax $obsvsb $minf "min" )    
mnA=$mno
echo $mnA > $mint
      
echo
echo "1.3. Calculate pdf function"
echo $mnA $mxA
cpdf $mnA $mxA $obsvsb $obsvout

else
echo 
echo "------------------------------- PROCCESSING ERA5 DATASET -------------------------------"

VAR="tp"

echo
echo "1.1. Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cpc.day.1979-2021.nc ${VAR}_${EXP}_${DATASET}_${YR}.nc
  
echo
echo "1.1. Define files"
obsvsb=${DIR_IN}/cpc.day.1979-2021.nc
obsvout=${VAR}_${DOMAIN}_${DATASET}_day_${YR}_pdf.nc

echo
echo "1.2. Calculate min and max"
maxf=${VAR}_max.nc
maxt=${VAR}_max.txt
mxo=$( fminmax $obsvsb $maxf "max" )
mxA=$mxo
echo $mxA > $maxt

minf=${VAR}_min.nc
mint=${VAR}_min.txt
mno=$( fminmax $obsvsb $minf "min" )    
mnA=$mno
echo $mnA > $mint
      
echo
echo "1.3. Calculate pdf function"
echo $mnA $mxA
cpdf $mnA $mxA $obsvsb $obsvout

fi

}
