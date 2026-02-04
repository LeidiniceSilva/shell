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
#__description__ = 'Calculate the p99/freq/int of OBS datasets with CDO'

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DATASET="ERA5"
DOMAIN="SAM-12"

YR="1971-1972"
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

VAR="tp"
echo
echo "1. Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/tp_ERA5_1hr_1970-1979.nc ${VAR}_${DATASET}_1hr_${YR}.nc
CDO mulc,1000 ${VAR}_${DATASET}_1hr_${YR}.nc ${VAR}_${DATASET}_${YR}.nc 
CDO daysum ${VAR}_${DATASET}_${YR}.nc ${VAR}_${DOMAIN}_${DATASET}_${YR}.nc

CDO timmin ${VAR}_${DOMAIN}_${DATASET}_${YR}.nc ${VAR}_${DOMAIN}_${DATASET}_${YR}_min.nc
CDO timmax ${VAR}_${DOMAIN}_${DATASET}_${YR}.nc ${VAR}_${DOMAIN}_${DATASET}_${YR}_max.nc
CDO timpctl,99 ${VAR}_${DOMAIN}_${DATASET}_${YR}.nc ${VAR}_${DOMAIN}_${DATASET}_${YR}_min.nc ${VAR}_${DOMAIN}_${DATASET}_${YR}_max.nc p99_${DOMAIN}_${DATASET}_${YR}.nc

for SEASON in ${SEASON_LIST[@]}; do
    CDO selseas,${SEASON} ${VAR}_${DOMAIN}_${DATASET}_${YR}.nc ${VAR}_${DOMAIN}_${DATASET}_${SEASON}_${YR}.nc

    CDO mulc,100 -histfreq,1,100000 ${VAR}_${DOMAIN}_${DATASET}_${SEASON}_${YR}.nc ${VAR}_freq_${DOMAIN}_${DATASET}_${SEASON}_${YR}.nc
    ${BIN}/./regrid ${VAR}_freq_${DOMAIN}_${DATASET}_${SEASON}_${YR}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil

    CDO histmean,1,100000 ${VAR}_${DOMAIN}_${DATASET}_${SEASON}_${YR}.nc ${VAR}_int_${DOMAIN}_${DATASET}_${SEASON}_${YR}.nc
    ${BIN}/./regrid ${VAR}_int_${DOMAIN}_${DATASET}_${SEASON}_${YR}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
done

echo 
echo "Delete files"
rm ${VAR}_${EXP}_${DATASET}_${YR}_min.nc
rm ${VAR}_${EXP}_${DATASET}_${YR}_max.nc

echo
echo "------------------------------- THE END POSTPROCESSING ${DATASET} -------------------------------"

}
