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
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 
{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DATASET=$1
DOMAIN="CSAM-3"
YEAR="2000"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/evaluate/test_bin/obs"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

if [ ${DATASET} == 'ERA5' ]
then
VAR="tp"

CDO selyear,${YEAR} ${DIR_IN}/${DATASET}/tp_ERA5_1hr_2000-2009.nc ${VAR}_${DOMAIN}_${DATASET}_1hr_${YEAR}.nc
CDO selmon,1 ${VAR}_${DOMAIN}_${DATASET}_1hr_${YEAR}.nc ${VAR}_${DOMAIN}_${DATASET}_1hr_${YEAR}01.nc
CDO daysum ${VAR}_${DOMAIN}_${DATASET}_1hr_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc
CDO monmean ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_mon_${YEAR}01.nc

CDO timmin ${VAR}_${DOMAIN}_${DATASET}_1hr_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_1hr_${YEAR}01_min.nc
CDO timmax ${VAR}_${DOMAIN}_${DATASET}_1hr_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_1hr_${YEAR}01_max.nc
CDO timpctl,99 ${VAR}_${DOMAIN}_${DATASET}_1hr_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_1hr_${YEAR}01_min.nc ${VAR}_${DOMAIN}_${DATASET}_1hr_${YEAR}01_max.nc p99_${DOMAIN}_${DATASET}_1hr_${YEAR}01.nc
CDO mulc,100 -histfreq,0.5,100000 ${VAR}_${DOMAIN}_${DATASET}_1hr_${YEAR}01.nc ${VAR}_freq_${DOMAIN}_${DATASET}_1hr_${YEAR}01_th0.5.nc
CDO histmean,0.5,100000 ${VAR}_${DOMAIN}_${DATASET}_1hr_${YEAR}01.nc ${VAR}_int_${DOMAIN}_${DATASET}_1hr_${YEAR}01_th0.5.nc

CDO timmin ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01_min.nc
CDO timmax ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01_max.nc
CDO timpctl,99 ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01_min.nc ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01_max.nc p99_${DOMAIN}_${DATASET}_day_${YEAR}01.nc
CDO mulc,100 -histfreq,1,100000 ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc ${VAR}_freq_${DOMAIN}_${DATASET}_day_${YEAR}01_th1.nc
CDO histmean,1,100000 ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc ${VAR}_int_${DOMAIN}_${DATASET}_day_${YEAR}01_th1.nc

${BIN}/./regrid ${VAR}_${DOMAIN}_${DATASET}_1hr_${YEAR}01.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid ${VAR}_${DOMAIN}_${DATASET}_mon_${YEAR}01.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

${BIN}/./regrid p99_${DOMAIN}_${DATASET}_1hr_${YEAR}01.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid ${VAR}_freq_${DOMAIN}_${DATASET}_1hr_${YEAR}01_th0.5.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid ${VAR}_int_${DOMAIN}_${DATASET}_1hr_${YEAR}01_th0.5.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

${BIN}/./regrid p99_${DOMAIN}_${DATASET}_day_${YEAR}01.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid ${VAR}_freq_${DOMAIN}_${DATASET}_day_${YEAR}01_th1.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid ${VAR}_int_${DOMAIN}_${DATASET}_day_${YEAR}01_th1.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

else
VAR="precip"

CDO selyear,${YEAR} ${DIR_IN}/${DATASET}/${VAR}.cpc.day.1979-2024.nc ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}.nc
CDO selmon,1 ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}.nc ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc
CDO monmean ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_mon_${YEAR}01.nc

CDO timmin ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01_min.nc
CDO timmax ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01_max.nc
CDO timpctl,99 ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01_min.nc ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01_max.nc p99_${DOMAIN}_${DATASET}_day_${YEAR}01.nc
CDO mulc,100 -histfreq,1,100000 ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc ${VAR}_freq_${DOMAIN}_${DATASET}_day_${YEAR}01_th1.nc
CDO histmean,1,100000 ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc ${VAR}_int_${DOMAIN}_${DATASET}_day_${YEAR}01_th1.nc

${BIN}/./regrid ${VAR}_${DOMAIN}_${DATASET}_day_${YEAR}01.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid ${VAR}_${DOMAIN}_${DATASET}_mon_${YEAR}01.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

${BIN}/./regrid p99_${DOMAIN}_${DATASET}_day_${YEAR}01.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid ${VAR}_freq_${DOMAIN}_${DATASET}_day_${YEAR}01_th1.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid ${VAR}_int_${DOMAIN}_${DATASET}_day_${YEAR}01_th1.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

fi

}
