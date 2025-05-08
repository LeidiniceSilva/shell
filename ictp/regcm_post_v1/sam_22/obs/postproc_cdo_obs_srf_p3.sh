#!/bin/bash

#SBATCH -A ICT25_ESP
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
#__description__ = 'Posprocessing the OBS datasets with CDO'

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DATASET=$1
EXP="SAM-22"

YR="1970-1971"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/${EXP}/postproc/obs"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "------------------------------- INIT POSTPROCESSING ${DATASET} -------------------------------"

if [ ${DATASET} == 'CPC' ]
then
VAR_LIST="precip"
for VAR in ${VAR_LIST[@]}; do
    echo
    echo "1. Select date"
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}.cpc.day.1979-2024.nc ${VAR}_${DATASET}_day_${YR}.nc
    echo
    echo "2. Monthly avg"
    CDO monmean ${VAR}_${DATASET}_day_${YR}.nc ${VAR}_${DATASET}_mon_${YR}.nc
    echo
    echo "3. Regrid variable"
    ${BIN}/./regrid ${VAR}_${DATASET}_day_${YR}.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil
    ${BIN}/./regrid ${VAR}_${DATASET}_mon_${YR}.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil
done

elif [ ${DATASET} == 'CRU' ]
then
VAR_LIST="pre tmp cld"
for VAR in ${VAR_LIST[@]}; do    
    echo
    echo "1. Select date"
    if [ ${VAR} == 'pre' ]
    then
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cru_ts4.08.1901.2023.${VAR}.dat.nc ${VAR}_${DATASET}_mon_${YR}.nc
    CDO -b f32 divc,30.5 ${VAR}_${DATASET}_mon_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    else
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cru_ts4.08.1901.2023.${VAR}.dat.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    fi
    echo
    echo "2. Regrid variable"
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil
done

elif [ ${DATASET} == 'ERA5' ]
then
VAR_LIST="tp"
for VAR in ${VAR_LIST[@]}; do
    echo
    echo "1. Select date"
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/tp_ERA5_1hr_1970-1979.nc ${VAR}_${DATASET}_${YR}.nc
    echo
    echo "2. Monthly avg"
    CDO -b f32 mulc,1000 ${VAR}_${DATASET}_${YR}.nc ${VAR}_${DATASET}_1hr_${YR}.nc
    CDO daysum ${VAR}_${DATASET}_1hr_${YR}.nc ${VAR}_${DATASET}_day_${YR}.nc
    CDO monmean ${VAR}_${DATASET}_day_${YR}.nc ${VAR}_${DATASET}_mon_${YR}.nc
    echo
    echo "3. Regrid variable"
    ${BIN}/./regrid ${VAR}_${DATASET}_1hr_${YR}.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil
    ${BIN}/./regrid ${VAR}_${DATASET}_day_${YR}.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil
    ${BIN}/./regrid ${VAR}_${DATASET}_mon_${YR}.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil
done
  
else
VAR_LIST="precipitation"
for VAR in ${VAR_LIST[@]}; do
    echo
    echo "1. Select date"
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/mswep.day.1979-2020.nc ${VAR}_${DATASET}_day_${YR}.nc
    echo
    echo "2. Monthly avg"
    CDO monmean ${VAR}_${DATASET}_day_${YR}.nc ${VAR}_${DATASET}_mon_${YR}.nc
    echo
    echo "3. Regrid variable"
    ${BIN}/./regrid ${VAR}_${DATASET}_day_${YR}.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil
    ${BIN}/./regrid ${VAR}_${DATASET}_mon_${YR}.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil
done
fi

echo
echo "Delete files"
rm *_${YR}.nc

echo
echo "------------------------------- THE END POSTPROCESSING ${DATASET} -------------------------------"

}
