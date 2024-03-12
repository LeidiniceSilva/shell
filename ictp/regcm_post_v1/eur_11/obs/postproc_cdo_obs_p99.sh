#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 12, 2024'
#__description__ = 'Calculate the p99 of OBS datasets with CDO'

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="2000-2000"

IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

VAR="precip"
EXP="EUR-11"
DATASET="CPC" 

DIR_IN="/marconi/home/userexternal/mdasilva/OBS"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/EUR-11/post_evaluate/obs"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo 
echo "------------------------------- INIT POSTPROCESSING DATASET -------------------------------"
   
echo
echo "1. Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cpc.day.1979-2021.nc ${VAR}_${EXP}_${DATASET}_${YR}.nc

echo
echo "2. Calculate p99"
CDO timmin ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_min.nc
CDO timmax ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_max.nc
CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_min.nc ${VAR}_${EXP}_${DATASET}_${YR}_max.nc p99_${EXP}_${DATASET}_${YR}.nc
  
echo
echo "3. Regrid variable"
${BIN}/./regrid p99_${EXP}_${DATASET}_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil

echo 
echo "4. Delete files"
rm ${VAR}_${EXP}_${DATASET}_${YR}.nc
rm ${VAR}_${EXP}_${DATASET}_${YR}_min.nc
rm ${VAR}_${EXP}_${DATASET}_${YR}_max.nc
rm p99_${EXP}_${DATASET}_${YR}.nc

echo
echo "------------------------------- THE END POSTPROCESSING DATASET -------------------------------"

}
