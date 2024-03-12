#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 12, 2024'
#__description__ = 'Posprocessing the OBS datasets with CDO'

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="2000-2000"

IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
 
EXP="EUR-11"
DATASET="MSWEP"
SEASON_LIST="DJF MAM JJA SON"

DIR_IN="/marconi/home/userexternal/mdasilva/OBS"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/EUR-11/post_evaluate/obs"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

if [ ${DATASET} == 'CPC' ]
then
echo 
echo "------------------------------- INIT POSTPROCESSING DATASET -------------------------------"

VAR_LIST="precip"
for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "1. Select date"
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cpc.day.1979-2021.nc ${VAR}_${DATASET}_day_${YR}.nc
    
    echo
    echo "2. Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        CDO -timmean -selseas,${SEASON} ${VAR}_${DATASET}_day_${YR}.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc
	${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
    done
    
done

echo 
echo "3. Delete files"
rm *_${YR}.nc

elif [ ${DATASET} == 'CRU' ]
then
echo 
echo "------------------------------- INIT POSTPROCESSING DATASET -------------------------------"

VAR_LIST="tmx tmn cld"
for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "1. Select date"
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}.dat.nc ${VAR}_${DATASET}_mon_${YR}.nc
    
    echo
    echo "2. Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        CDO -timmean -selseas,${SEASON} ${VAR}_${DATASET}_mon_${YR}.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc
	${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
    done
      
done

echo 
echo "3. Delete files"
rm *_${YR}.nc

elif [ ${DATASET} == 'EOBS' ]
then
echo 
echo "------------------------------- INIT POSTPROCESSING DATASET -------------------------------"

VAR_LIST="rr tg"
for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "1. Select date"
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}.nc ${VAR}_${DATASET}_day_${YR}.nc

    echo
    echo "2. Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        CDO -timmean -selseas,${SEASON} ${VAR}_${DATASET}_day_${YR}.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc
	${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
    done

done

echo 
echo "3. Delete files"
rm *_${YR}.nc
  
else
echo 
echo "------------------------------- INIT POSTPROCESSING DATASET -------------------------------"

VAR_LIST="precipitation"
for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "1. Select date"
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/mswep.mon.1979-2020.nc ${VAR}_${DATASET}_mon_${YR}.nc

    echo
    echo "2. Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        CDO -timmean -selseas,${SEASON} ${VAR}_${DATASET}_mon_${YR}.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc
	${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
    done

done

echo 
echo "3. Delete files"
rm *_${YR}.nc

fi

echo
echo "------------------------------- THE END POSTPROCESSING DATASET -------------------------------"

}
