#!/bin/bash

#SBATCH -A ICT23_ESP_1
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 12, 2024'
#__description__ = 'Calculate the p99 of OBS datasets with CDO'

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DATASET=$1
EXP="EUR-11"

YR="1970-1970"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/postproc/obs"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo 
echo "------------------------------- INIT POSTPROCESSING ${DATASET} -------------------------------"

if [ ${DATASET} == 'CPC' ]
then
VAR="precip"

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

elif [ ${DATASET} == 'ERA5' ]
then
VAR="pr"

echo
echo "1. Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/pr_ERA5_hr_2000-2009.nc ${VAR}_${DATASET}_hr_${YR}.nc
CDO daysum ${VAR}_${DATASET}_hr_${YR}.nc ${VAR}_${DATASET}_${YR}.nc
CDO mulc,1000 ${VAR}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}.nc

echo
echo "2. Calculate p99"
CDO timmin ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_min.nc
CDO timmax ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_max.nc
CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_min.nc ${VAR}_${EXP}_${DATASET}_${YR}_max.nc p99_${EXP}_${DATASET}_${YR}.nc

echo
echo "3. Regrid variable"
${BIN}/./regrid p99_${EXP}_${DATASET}_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil


elif [ ${DATASET} == 'MSWEP' ]
then
VAR="precipitation"

echo
echo "1. Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/mswep.day.1979-2020.nc ${VAR}_${EXP}_${DATASET}_${YR}.nc

echo
echo "2. Calculate p99"
CDO timmin ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_min.nc
CDO timmax ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_max.nc
CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_min.nc ${VAR}_${EXP}_${DATASET}_${YR}_max.nc p99_${EXP}_${DATASET}_${YR}.nc

echo
echo "3. Regrid variable"
${BIN}/./regrid p99_${EXP}_${DATASET}_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil

else
VAR="rr"

echo
echo "1. Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/rr.nc ${VAR}_${EXP}_${DATASET}_${YR}.nc

echo
echo "2. Calculate p99"
CDO timmin ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_min.nc
CDO timmax ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_max.nc
CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_min.nc ${VAR}_${EXP}_${DATASET}_${YR}_max.nc p99_${EXP}_${DATASET}_${YR}.nc
  
echo
echo "3. Regrid variable"
${BIN}/./regrid p99_${EXP}_${DATASET}_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil

fi

echo 
echo "Delete files"
rm *_${YR}.nc
rm ${VAR}_${EXP}_${DATASET}_${YR}_min.nc
rm ${VAR}_${EXP}_${DATASET}_${YR}_max.nc

echo
echo "------------------------------- THE END POSTPROCESSING ${DATASET} -------------------------------"

}
