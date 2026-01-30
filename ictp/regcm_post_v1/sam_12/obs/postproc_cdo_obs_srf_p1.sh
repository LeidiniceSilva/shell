#!/bin/bash

#SBATCH -A CMPNS_ictpclim
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jan 30, 2026'
#__description__ = 'Posprocessing the OBS datasets with CDO'

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DATASET=$1
DOMAIN="SAM-12"

YR="1970-1971"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/${DOMAIN}/postproc/obs"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "------------------------------- INIT POSTPROCESSING ${DATASET} -------------------------------"

if [ ${DATASET} == 'CRU' ]
then
VAR_LIST="pre tmp"
for VAR in ${VAR_LIST[@]}; do
    echo
    echo "1. Select date"
    if [ ${VAR} == 'pre' ]
    then
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cru_ts4.08.1901.2023.${VAR}.dat.nc ${VAR}_${DATASET}_${YR}.nc
    CDO divc,30.5 ${VAR}_${DATASET}_${YR}.nc ${VAR}_${DATASET}_mon_${YR}.nc 
    else
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cru_ts4.08.1901.2023.${VAR}.dat.nc ${VAR}_${DATASET}_mon_${YR}.nc
    fi
    echo
    echo "2. Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        CDO -timmean -selseas,${SEASON} ${VAR}_${DATASET}_mon_${YR}.nc ${VAR}_${DOMAIN}_${DATASET}_${SEASON}_${YR}.nc
	${BIN}/./regrid ${VAR}_${DOMAIN}_${DATASET}_${SEASON}_${YR}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    done
done

else
VAR_LIST="tp t2m"
for VAR in ${VAR_LIST[@]}; do
    echo
    echo "1. Select date"
    if [ ${VAR} == 'tp' ]
    then
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}_ERA5_1hr_1970-1979.nc ${VAR}_${DATASET}_1hr_${YR}.nc
    CDO mulc,1000 ${VAR}_${DATASET}_1hr_${YR}.nc ${VAR}_${DOMAIN}_${DATASET}_1hr_${YR}.nc 
    CDO daysum ${VAR}_${DOMAIN}_${DATASET}_1hr_${YR}.nc ${VAR}_${DOMAIN}_${DATASET}_day_${YR}.nc 
    CDO monmean ${VAR}_${DOMAIN}_${DATASET}_day_${YR}.nc ${VAR}_${DOMAIN}_${DATASET}_mon_${YR}.nc 
    else
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}_ERA5_1970-1979.nc ${VAR}_${DATASET}_${YR}.nc
    CDO subc,273.15 ${VAR}_${DATASET}_${YR}.nc ${VAR}_${DOMAIN}_${DATASET}_mon_${YR}.nc
    fi
    echo
    echo "2. Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        CDO -timmean -selseas,${SEASON} ${VAR}_${DOMAIN}_${DATASET}_mon_${YR}.nc ${VAR}_${DOMAIN}_${DATASET}_${SEASON}_${YR}.nc
        ${BIN}/./regrid ${VAR}_${DOMAIN}_${DATASET}_${SEASON}_${YR}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    done
done
fi

echo
echo "Delete files"
rm *_${YR}.nc

echo
echo "------------------------------- THE END POSTPROCESSING ${DATASET} -------------------------------"

}
