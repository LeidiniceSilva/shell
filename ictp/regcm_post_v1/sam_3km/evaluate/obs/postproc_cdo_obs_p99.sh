#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the OBS datasets with CDO'

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DATASET="ERA5"

EXP="SAM-3km"
DT="2018-2021"
DT_i="2018-01-01"
DT_ii="2021-12-31"

DIR_IN="/marconi/home/userexternal/mdasilva/OBS"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_evaluate/obs"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

if [ ${DATASET} == 'CPC' ]
then
echo 
echo "1. ------------------------------- PROCCESSING CPC DATASET -------------------------------"

VAR="precip"
    
echo
echo "1.1. Select date"
CDO seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/cpc.day.1979-2021.nc ${VAR}_${EXP}_${DATASET}_${DT}.nc

echo
echo "1.2. Calculate p99"
CDO timmin ${VAR}_${EXP}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_${DT}_min.nc
CDO timmax ${VAR}_${EXP}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_${DT}_max.nc
CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_${DT}_min.nc ${VAR}_${EXP}_${DATASET}_${DT}_max.nc p99_${EXP}_${DATASET}_${DT}.nc
  
echo
echo "1.3. Regrid variable"
${BIN}/./regrid p99_${EXP}_${DATASET}_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo 
echo "1.4. Delete files"
rm ${VAR}_${EXP}_${DATASET}_${DT}.nc
rm ${VAR}_${EXP}_${DATASET}_${DT}_min.nc
rm ${VAR}_${EXP}_${DATASET}_${DT}_max.nc
rm p99_${EXP}_${DATASET}_${DT}.nc

else
echo 
echo "2. ------------------------------- PROCCESSING ERA5 DATASET -------------------------------"

VAR="tp"
    
echo
echo "2.1. Convert unit"
CDO -b f32 mulc,1000 ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_${DT}.nc

echo
echo "2.2. Calculate p99"
CDO timmin ${VAR}_${EXP}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_${DT}_min.nc
CDO timmax ${VAR}_${EXP}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_${DT}_max.nc
CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_${DT}_min.nc ${VAR}_${EXP}_${DATASET}_${DT}_max.nc p99_${EXP}_${DATASET}_${DT}.nc
  
echo
echo "2.3. Regrid variable"
${BIN}/./regrid p99_${EXP}_${DATASET}_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo 
echo "2.4. Delete files"
rm ${VAR}_${EXP}_${DATASET}_${DT}.nc
rm ${VAR}_${EXP}_${DATASET}_${DT}_min.nc
rm ${VAR}_${EXP}_${DATASET}_${DT}_max.nc
rm p99_${EXP}_${DATASET}_${DT}.nc

fi

}
