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
SEASON_LIST="DJF MAM JJA SON"

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
echo "Frequency and intensity by season"
for SEASON in ${SEASON_LIST[@]}; do
    CDO selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc
    
    CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc ${VAR}_freq_${EXP}_${DATASET}_${SEASON}_${YR}.nc
    ${BIN}/./regrid ${VAR}_freq_${EXP}_${DATASET}_${SEASON}_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

    CDO histmean,1,100000 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc ${VAR}_int_${EXP}_${DATASET}_${SEASON}_${YR}.nc
    ${BIN}/./regrid ${VAR}_int_${EXP}_${DATASET}_${SEASON}_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
done

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
echo "Frequency and intensity by season"
for SEASON in ${SEASON_LIST[@]}; do
    CDO selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc
    
    CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc ${VAR}_freq_${EXP}_${DATASET}_${SEASON}_${YR}.nc
    ${BIN}/./regrid ${VAR}_freq_${EXP}_${DATASET}_${SEASON}_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

    CDO histmean,1,100000 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc ${VAR}_int_${EXP}_${DATASET}_${SEASON}_${YR}.nc
    ${BIN}/./regrid ${VAR}_int_${EXP}_${DATASET}_${SEASON}_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
done

else
echo 
echo "------------------------------- PROCCESSING ${DATASET} DATASET -------------------------------"

VAR="hrf"

echo
echo "Merge files"
FILE=$( eval ls ${DIR_IN}/${DATASET}/TRMM.day.mean.????.nc )
CDO mergetime ${FILE} ${VAR}_${DATASET}_1998-2009.nc

echo
echo "Select date"
CDO selyear,${IYR}/${FYR} ${VAR}_${DATASET}_1998-2009.nc ${VAR}_${EXP}_${DATASET}_${YR}.nc

echo
echo "Frequency and intensity by season"
for SEASON in ${SEASON_LIST[@]}; do
    CDO selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc
    
    CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc ${VAR}_freq_${EXP}_${DATASET}_${SEASON}_${YR}.nc
    ${BIN}/./regrid ${VAR}_freq_${EXP}_${DATASET}_${SEASON}_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

    CDO histmean,1,100000 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc ${VAR}_int_${EXP}_${DATASET}_${SEASON}_${YR}.nc
    ${BIN}/./regrid ${VAR}_int_${EXP}_${DATASET}_${SEASON}_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
done

fi

echo 
echo "2.4. Delete files"
rm *2009.nc

}
