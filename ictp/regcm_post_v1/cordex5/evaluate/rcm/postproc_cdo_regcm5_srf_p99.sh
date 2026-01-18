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
#__description__ = 'Calculate the p99 of RegCM5 with CDO'
 
{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

VAR="pr"
FREQ="day"
DOMAIN="CSAM-3"
EXP="ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1"

YR="2000-2000"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/ERA5/ERA5-CSAM/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/${FREQ}/${VAR}"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/evaluate/rcm"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo 
echo "Concatenate date"
CDO mergetime ${DIR_IN}/${VAR}_${DOMAIN}_${EXP}_${FREQ}_2000*.nc ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc
    
echo
echo "Convert unit"
CDO -b f32 mulc,86400 ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_${YR}.nc

echo
echo "Calculate p99"
CDO timmin ${VAR}_${DOMAIN}_RegCM5_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_${YR}_min.nc
CDO timmax ${VAR}_${DOMAIN}_RegCM5_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_${YR}_max.nc
CDO timpctl,99 ${VAR}_${DOMAIN}_RegCM5_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_${YR}_min.nc ${VAR}_${DOMAIN}_RegCM5_${YR}_max.nc p99_${DOMAIN}_RegCM5_${YR}.nc
  
echo
echo "Regrid variable"
${BIN}/./regrid p99_${DOMAIN}_RegCM5_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

echo 
echo "Delete files"
rm ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc
rm ${VAR}_${DOMAIN}_RegCM5_${YR}.nc
rm ${VAR}_${DOMAIN}_RegCM5_${YR}_min.nc
rm ${VAR}_${DOMAIN}_RegCM5_${YR}_max.nc
rm p99_${DOMAIN}_RegCM5_${YR}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
