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

DATASET=$1
EXP="EUR-11"

YR="2000-2001"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/postproc/obs"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

if [ ${DATASET} == 'CPC' ]
then
echo 
echo "------------------------------- INIT POSTPROCESSING ${DATASET} -------------------------------"

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
echo "------------------------------- INIT POSTPROCESSING ${DATASET} -------------------------------"

VAR_LIST="pre tmp"
for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "1. Select date"
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cru_ts4.08.1901.2023.${VAR}.dat.nc ${VAR}_${DATASET}_mon_${YR}.nc
   
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
echo "------------------------------- INIT POSTPROCESSING ${DATASET} -------------------------------"

VAR_LIST="rr"
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

elif [ ${DATASET} == 'ERA5' ]
then
echo 
echo "------------------------------- INIT POSTPROCESSING ${DATASET} -------------------------------"

VAR_LIST="rr"
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
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/mswep.day.1979-2020.nc ${VAR}_${DATASET}_day_${YR}.nc

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

fi

echo
echo "------------------------------- THE END POSTPROCESSING DATASET -------------------------------"

}
