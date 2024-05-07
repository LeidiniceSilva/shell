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

YR="2000-2000"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

EXP="EUR-11"
DATASET="MSWEP"

DIR_IN="/marconi/home/userexternal/mdasilva/OBS"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/EUR-11/obs_v2"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

if [ ${DATASET} == 'CPC' ]
then
echo 
echo "------------------------------- INIT POSTPROCESSING DATASET -------------------------------"

VAR="precip"

echo
echo "1. Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cpc.day.1979-2021.nc ${VAR}_${EXP}_${DATASET}_${IYR}.nc

for MON in `seq -w 01 01`; do
	CDO selmonth,${MON} ${VAR}_${EXP}_${DATASET}_${IYR}.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc
	
	echo
	echo "2. Calculate mon mean"
	CDO monmean ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}.nc

	echo
	echo "3. Calculate p99"
	CDO timmin ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_min.nc
	CDO timmax ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_max.nc
	CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_min.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_max.nc p99_${EXP}_${DATASET}_${IYR}${MON}01.nc
  
	echo
	echo "4. Frequency and intensity by season"
	CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_freq_${EXP}_${DATASET}_${IYR}${MON}01.nc
	CDO histmean,1,100000 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_int_${EXP}_${DATASET}_${IYR}${MON}01.nc

	echo
	echo "5. Regrid"
	${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_${IYR}${MON}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	${BIN}/./regrid p99_${EXP}_${DATASET}_${IYR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	${BIN}/./regrid ${VAR}_freq_${EXP}_${DATASET}_${IYR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	${BIN}/./regrid ${VAR}_int_${EXP}_${DATASET}_${IYR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
done

elif [ ${DATASET} == 'EOBS' ]
then
echo 
echo "------------------------------- INIT POSTPROCESSING DATASET -------------------------------"

VAR="rr"

echo
echo "1. Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}.nc ${VAR}_${EXP}_${DATASET}_${IYR}.nc

for MON in `seq -w 01 01`; do
	CDO selmonth,${MON} ${VAR}_${EXP}_${DATASET}_${IYR}.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc
	
	echo
	echo "2. Calculate mon mean"
	CDO monmean ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}.nc

	echo
	echo "3. Calculate p99"
	CDO timmin ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_min.nc
	CDO timmax ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_max.nc
	CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_min.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_max.nc p99_${EXP}_${DATASET}_${IYR}${MON}01.nc
  
	echo
	echo "4. Frequency and intensity by season"
	CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_freq_${EXP}_${DATASET}_${IYR}${MON}01.nc
	CDO histmean,1,100000 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_int_${EXP}_${DATASET}_${IYR}${MON}01.nc

	echo
	echo "5. Regrid"
	${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_${IYR}${MON}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	${BIN}/./regrid p99_${EXP}_${DATASET}_${IYR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	${BIN}/./regrid ${VAR}_freq_${EXP}_${DATASET}_${IYR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	${BIN}/./regrid ${VAR}_int_${EXP}_${DATASET}_${IYR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
done

else
echo 
echo "------------------------------- INIT POSTPROCESSING DATASET -------------------------------"

VAR="precipitation"

echo
echo "1. Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/mswep.mon.1979-2020.nc ${VAR}_${EXP}_${DATASET}_${IYR}.nc

for MON in `seq -w 01 01`; do
	CDO selmonth,${MON} ${VAR}_${EXP}_${DATASET}_${IYR}.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc
	
	echo
	echo "2. Calculate mon mean"
	CDO divc,30.5 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}.nc

	echo
	echo "5. Regrid"
	${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_${IYR}${MON}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
done

fi

echo 
echo "6. Delete files"
rm *_${EXP}_${DATASET}_${IYR}.nc
rm *_${EXP}_${DATASET}_${IYR}${MON}01.nc
rm *_${EXP}_${DATASET}_${IYR}${MON}01_min.nc
rm *_${EXP}_${DATASET}_${IYR}${MON}01_max.nc
rm *_${EXP}_${DATASET}_${IYR}${MON}.nc

}
