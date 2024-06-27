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

YR="2018-2021"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

DATASET="GPM"
EXP="SAM-3km"

DIR_IN="/marconi/home/userexternal/mdasilva/OBS"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_evaluate/obs"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo 
echo "------------------------------- PROCCESSING ${DATASET} DATASET -------------------------------"

if [ ${DATASET} == 'ERA5' ] 
then

VAR="tp"

echo
echo "1.1. Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_1hr_2018-2021.nc ${VAR}_${DATASET}_1hr_${YR}.nc
   
echo
echo "1.2. Convert unit"
CDO -b f32 mulc,1000 ${VAR}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc

echo
echo "1.3. Calculate p99"
CDO timmin ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}_min.nc
CDO timmax ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}_max.nc
CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}_min.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}_max.nc p99_${EXP}_${DATASET}_1hr_${YR}.nc
  
echo
echo "1.4. Regrid variable"
${BIN}/./regrid p99_${EXP}_${DATASET}_1hr_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
             
else

VAR="precipitation"

echo
echo "1.1. Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/precipitation_SAM-10km_GPM_3B-V0A7_1hr_2018-2021.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc

echo
echo "1.2. Calculate p99"
CDO timmin ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}_min.nc
CDO timmax ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}_max.nc
CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}_min.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}_max.nc p99_${EXP}_${DATASET}_1hr_${YR}.nc
  
echo
echo "1.3. Regrid variable"
${BIN}/./regrid p99_${EXP}_${DATASET}_1hr_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

fi
 
echo 
echo "Delete files"
rm *_${YR}.nc
rm ${VAR}_${EXP}_${DATASET}_1hr_${YR}_min.nc
rm ${VAR}_${EXP}_${DATASET}_1hr_${YR}_max.nc
  
}
