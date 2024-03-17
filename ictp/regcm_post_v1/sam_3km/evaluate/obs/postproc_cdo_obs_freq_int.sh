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

EXP="SAM-3km"
DATASET="CPC"

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
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cpc.day.1979-2021.nc ${VAR}_${EXP}_${DATASET}_${YR}.nc

echo
echo "1.2. Frequency and intensity by season"
for SEASON in ${SEASON_LIST[@]}; do
    CDO selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc
    
    CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc ${VAR}_freq_${EXP}_${DATASET}_${SEASON}_${YR}.nc
    ${BIN}/./regrid ${VAR}_freq_${EXP}_${DATASET}_${SEASON}_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

    CDO histmean,1,100000 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc ${VAR}_int_${EXP}_${DATASET}_${SEASON}_${YR}.nc
    ${BIN}/./regrid ${VAR}_int_${EXP}_${DATASET}_${SEASON}_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
done

echo 
echo "1.3. Delete files"
rm *_${YR}.nc

else
echo 
echo "2. ------------------------------- PROCCESSING ERA5 DATASET -------------------------------"

VAR="tp"

echo
echo "2.1. Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_2018-2021.nc ${VAR}_${DATASET}_${YR}.nc
    
echo
echo "2.2. Convert unit"
CDO -b f32 mulc,1000 ${VAR}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}.nc

echo
echo "2.3. Frequency and intensity by season"
for SEASON in ${SEASON_LIST[@]}; do
    CDO selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc
    
    CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc ${VAR}_freq_${EXP}_${DATASET}_${SEASON}_${YR}.nc
    ${BIN}/./regrid ${VAR}_freq_${EXP}_${DATASET}_${SEASON}_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

    CDO histmean,1,100000 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc ${VAR}_int_${EXP}_${DATASET}_${SEASON}_${YR}.nc
    ${BIN}/./regrid ${VAR}_int_${EXP}_${DATASET}_${SEASON}_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
done

echo 
echo "2.4. Delete files"
rm *_${YR}.nc

fi

}
