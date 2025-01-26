#!/bin/bash

#SBATCH -N 1 
#SBATCH -t 24:00:00
#SBATCH -A ICT23_ESP
#SBATCH --qos=qos_prio
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p skl_usr_prod

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Calculate the p99 of RegCM5 with CDO'
 
{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="2000-2005"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

VAR="pr"
FREQ="day"
DOMAIN="CSAM-3"
EXP="ERA5_evaluation_r1i1p1f1_ICTP_RegCM5"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/CORDEX/ERA5/ERA5-CSAM-3/CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5/v1-r1/${FREQ}/${VAR}"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/CORDEX/post_evaluate/rcm"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo 
echo "Concatenate date"
CDO mergetime ${DIR_IN}/${VAR}_${DOMAIN}_${EXP}_v1-r1_${FREQ}_*.nc ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc
    
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
rm *_${YR}.nc
rm *_min.nc 
rm *_max.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
