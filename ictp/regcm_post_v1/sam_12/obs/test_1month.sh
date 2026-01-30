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
#__description__ = 'Posprocessing the OBS output with CDO'
 
{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DATASET=$1
DOMAIN="SAM-12"
YEAR="1970"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/${DOMAIN}/postproc/obs"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

if [ ${DATASET} == 'ERA5' ]
then
VAR_LIST="tp t2m"
for VAR in ${VAR_LIST[@]}; do
    if [ ${VAR} == 'tp' ]
    then
    CDO selyear,${YEAR} ${DIR_IN}/${DATASET}/${VAR}_ERA5_1hr_1970-1979.nc ${VAR}_${DATASET}_1hr_${YEAR}.nc
    CDO selmon,1 ${VAR}_${DATASET}_1hr_${YEAR}.nc ${VAR}_${DATASET}_1hr_${YEAR}01.nc
    CDO mulc,1000 ${VAR}_${DATASET}_1hr_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_1hr_${YEAR}01.nc
    CDO daysum ${VAR}_${DOMAIN}_${DATASET}_1hr_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc
    CDO monmean ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_mon_${YEAR}01.nc
    CDO timmin ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01_min.nc
    CDO timmax ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01_max.nc
    CDO timpctl,99 ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01_min.nc ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01_max.nc p99_${DOMAIN}_${DATASET}_day_${YEAR}01.nc
    CDO mulc,100 -histfreq,1,100000 ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc ${VAR}_freq_${DOMAIN}_${DATASET}_day_${YEAR}01_th1.nc
    CDO histmean,1,100000 ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc ${VAR}_int_${DOMAIN}_${DATASET}_day_${YEAR}01_th1.nc
    ${BIN}/./regrid ${VAR}_${DOMAIN}_${DATASET}_1hr_${YEAR}01.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    ${BIN}/./regrid ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    ${BIN}/./regrid ${VAR}_${DOMAIN}_${DATASET}_mon_${YEAR}01.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    ${BIN}/./regrid p99_${DOMAIN}_${DATASET}_day_${YEAR}01.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    ${BIN}/./regrid ${VAR}_freq_${DOMAIN}_${DATASET}_day_${YEAR}01_th1.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    ${BIN}/./regrid ${VAR}_int_${DOMAIN}_${DATASET}_day_${YEAR}01_th1.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    else
    CDO selyear,${YEAR} ${DIR_IN}/${DATASET}/${VAR}_ERA5_1970-1979.nc ${VAR}_${DATASET}_${YEAR}.nc
    CDO selmon,1 ${VAR}_${DATASET}_${YEAR}.nc ${VAR}_${DATASET}_mon_${YEAR}01.nc
    CDO subc,273.15 ${VAR}_${DATASET}_mon_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_mon_${YEAR}01.nc
    ${BIN}/./regrid ${VAR}_${DOMAIN}_${DATASET}_mon_${YEAR}01.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    fi
done

else
VAR_LIST="pre tmp"
for VAR in ${VAR_LIST[@]}; do
    CDO selyear,${YEAR} ${DIR_IN}/${DATASET}/cru_ts4.08.1901.2023.${VAR}.dat.nc ${VAR}_${DOMAIN}_${DATASET}_${YEAR}.nc
    CDO selmon,1 ${VAR}_${DOMAIN}_${DATASET}_${YEAR}.nc ${VAR}_${DOMAIN}_${DATASET}_${YEAR}01.nc
    if [ ${VAR} == 'pre' ]
    then
    CDO divc,30.5 ${VAR}_${DOMAIN}_${DATASET}_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_mon_${YEAR}01.nc
    else
    cp ${VAR}_${DOMAIN}_${DATASET}_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_mon_${YEAR}01.nc
    fi
    ${BIN}/./regrid ${VAR}_${DOMAIN}_${DATASET}_mon_${YEAR}01.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
done
fi

}
