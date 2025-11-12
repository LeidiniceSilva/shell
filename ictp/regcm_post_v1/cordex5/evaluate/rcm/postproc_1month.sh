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

VAR="pr"
DOMAIN="CSAM-3"
YEAR="2000"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/ERA5/ERA5-CSAM"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/evaluate/test_bin/era5-csam"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for DAY in `seq -w 01 31`; do
    CDO selname,${VAR} ${DIR_IN}/${DOMAIN}_SRF.${YEAR}01${DAY}00.nc ${VAR}_${DOMAIN}_${YEAR}01${DAY}00.nc
done

CDO mergetime ${VAR}_${DOMAIN}_${YEAR}01${DAY}00.nc ${VAR}_${DOMAIN}_${YEAR}01.nc 
CDO -b f32 mulc,3600 ${VAR}_${DOMAIN}_${YEAR}01.nc ${VAR}_${DOMAIN}_1hr_${YEAR}01.nc 
CDO daysum ${VAR}_${DOMAIN}_1hr_${YEAR}01.nc ${VAR}_${DOMAIN}_day_${YEAR}01.nc
CDO monmean ${VAR}_${DOMAIN}_day_${YEAR}01.nc ${VAR}_${DOMAIN}_mon_${YEAR}01.nc

CDO timmin ${VAR}_${DOMAIN}_day_${YEAR}01.nc ${VAR}_${DOMAIN}_day_${YEAR}01_min.nc
CDO timmax ${VAR}_${DOMAIN}_day_${YEAR}01.nc ${VAR}_${DOMAIN}_day_${YEAR}01_max.nc
CDO timpctl,99 ${VAR}_${DOMAIN}_day_${YEAR}01.nc ${VAR}_${DOMAIN}_day_${YEAR}01_min.nc ${VAR}_${DOMAIN}_day_${YEAR}01_max.nc p99_${DOMAIN}_day_${YEAR}01.nc
CDO mulc,100 -histfreq,1,100000 ${VAR}_${DOMAIN}_day_${YEAR}01.nc ${VAR}_freq_${DOMAIN}_day_${YEAR}01_th1.nc
CDO histmean,1,100000 ${VAR}_${DOMAIN}_day_${YEAR}01.nc ${VAR}_int_${DOMAIN}_day_${YEAR}01_th1.nc

CDO timmin ${VAR}_${DOMAIN}_1hr_${YEAR}01.nc ${VAR}_${DOMAIN}_1hr_${YEAR}01_min.nc
CDO timmax ${VAR}_${DOMAIN}_1hr_${YEAR}01.nc ${VAR}_${DOMAIN}_1hr_${YEAR}01_max.nc
CDO timpctl,99 ${VAR}_${DOMAIN}_1hr_${YEAR}01.nc ${VAR}_${DOMAIN}_1hr_${YEAR}01_min.nc ${VAR}_${DOMAIN}_1hr_${YEAR}01_max.nc p99_${DOMAIN}_1hr_${YEAR}01.nc
CDO mulc,100 -histfreq,0.5,100000 ${VAR}_${DOMAIN}_1hr_${YEAR}01.nc ${VAR}_freq_${DOMAIN}_1hr_${YEAR}01_th0.5.nc
CDO histmean,0.5,100000 ${VAR}_${DOMAIN}_1hr_${YEAR}01.nc ${VAR}_int_${DOMAIN}_1hr_${YEAR}01_th0.5.nc

${BIN}/./regrid ${VAR}_${DOMAIN}_1hr_${YEAR}01.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid ${VAR}_${DOMAIN}_day_${YEAR}01.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid ${VAR}_${DOMAIN}_mon_${YEAR}01.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

${BIN}/./regrid p99_${DOMAIN}_1hr_${YEAR}01.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid ${VAR}_freq_${DOMAIN}_1hr_${YEAR}01_th0.5.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid ${VAR}_int_${DOMAIN}_1hr_${YEAR}01_th0.5.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

${BIN}/./regrid p99_${DOMAIN}_day_${YEAR}01.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid ${VAR}_freq_${DOMAIN}_day_${YEAR}01_th1.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid ${VAR}_int_${DOMAIN}_day_${YEAR}01_th1.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
