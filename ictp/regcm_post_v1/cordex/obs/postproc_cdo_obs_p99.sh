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

YR="2000-2009"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

DATASET=$1
EXP="CSAM-3"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/OBS"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/CORDEX/post_evaluate/obs"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

if [ ${DATASET} == 'CPC' ]
then
echo 
echo "------------------------------- PROCCESSING ${DATASET} DATASET -------------------------------"

VAR="precip"
    
echo
echo "Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cpc.day.1979-2021.nc ${VAR}_${EXP}_${DATASET}_${YR}.nc

echo
echo "Calculate p99"
CDO timmin ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_min.nc
CDO timmax ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_max.nc
CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_min.nc ${VAR}_${EXP}_${DATASET}_${YR}_max.nc p99_${EXP}_${DATASET}_${YR}.nc
  
echo
echo "Regrid variable"
${BIN}/./regrid p99_${EXP}_${DATASET}_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

elif [ ${DATASET} == 'ERA5' ]
then
echo 
echo "------------------------------- PROCCESSING ${DATASET} DATASET -------------------------------"

VAR="pr"

echo
echo "Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_1hr_2000-2009.nc ${VAR}_${DATASET}_1hr_2000-2009.nc
    
echo
echo "Convert unit"
CDO -b f32 mulc,1000 ${VAR}_${DATASET}_1hr_2000-2009.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc
CDO daysum ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}.nc

echo
echo "Calculate p99"
CDO timmin ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_min.nc
CDO timmax ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_max.nc
CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_min.nc ${VAR}_${EXP}_${DATASET}_${YR}_max.nc p99_${EXP}_${DATASET}_${YR}.nc
  
echo
echo "Regrid variable"
${BIN}/./regrid p99_${EXP}_${DATASET}_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

else
echo 
echo "------------------------------- PROCCESSING ${DATASET} DATASET -------------------------------"

VAR="hrf"

echo
echo "Select date"
FILE=$( eval ls ${DIR_IN}/${DATASET}/TRMM.day.mean.????.nc )
CDO mergetime ${FILE} ${VAR}_${DATASET}_1998-2009.nc

echo
echo "Select date"
CDO selyear,${IYR}/${FYR} ${VAR}_${DATASET}_1998-2009.nc ${VAR}_${EXP}_${DATASET}_${YR}.nc

echo
echo "Calculate p99"
CDO timmin ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_min.nc
CDO timmax ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_max.nc
CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_min.nc ${VAR}_${EXP}_${DATASET}_${YR}_max.nc p99_${EXP}_${DATASET}_${YR}.nc
  
echo
echo "Regrid variable"
${BIN}/./regrid p99_${EXP}_${DATASET}_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

fi

echo 
echo "Delete files"
rm *_${YR}.nc
rm *_min.nc
rm *_max.nc

}
