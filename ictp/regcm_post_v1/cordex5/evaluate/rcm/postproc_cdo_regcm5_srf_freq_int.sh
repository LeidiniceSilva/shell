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
#__date__        = 'Nov 20, 2023'
#__description__ = 'Calculate the freq and int of RegCM5 with CDO'
 
{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

VAR="pr"
FREQ="day"
DOMAIN="CSAM-3"
EXP="ERA5_evaluation_r1i1p1f1_ICTP_RegCM5"

YR="2000-2001"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/ERA5/ERA5-CSAM-3/CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5/v1-r1/${FREQ}/${VAR}"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/rcm"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo 
echo "Concatenate date"
CDO mergetime ${DIR_IN}/${VAR}_${DOMAIN}_${EXP}_v1-r1_${FREQ}_*.nc ${VAR}_${DOMAIN}_${EXP}_${YR}.nc
    
echo
echo "Convert unit"
CDO -b f32 mulc,86400 ${VAR}_${DOMAIN}_${EXP}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_${YR}.nc

echo
echo "Frequency and intensity by season"
for SEASON in ${SEASON_LIST[@]}; do

    CDO selseas,${SEASON} ${VAR}_${DOMAIN}_RegCM5_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_${SEASON}_${YR}.nc
    
    CDO mulc,100 -histfreq,1,100000 ${VAR}_${DOMAIN}_RegCM5_${SEASON}_${YR}.nc ${VAR}_freq_${DOMAIN}_RegCM5_${SEASON}_${YR}.nc
    ${BIN}/./regrid ${VAR}_freq_${DOMAIN}_RegCM5_${SEASON}_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

    CDO histmean,1,100000 ${VAR}_${DOMAIN}_RegCM5_${SEASON}_${YR}.nc ${VAR}_int_${DOMAIN}_RegCM5_${SEASON}_${YR}.nc
    ${BIN}/./regrid ${VAR}_int_${DOMAIN}_RegCM5_${SEASON}_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

done

echo 
echo "Delete files"
rm *_${YR}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
