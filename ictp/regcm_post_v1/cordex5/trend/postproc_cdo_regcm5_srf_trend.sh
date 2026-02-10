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
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DOMAIN="CSAM-3"
EXP="ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1"

FREQ="day"
YR="2000-2009"
VAR_LIST="pr tas tasmax tasmin"

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/evaluate/rcm"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "Select variable"
for VAR in ${VAR_LIST[@]}; do

    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/ERA5/ERA5-CSAM/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/${FREQ}/${VAR}"

    echo
    echo "Merge files"
    CDO mergetime ${DIR_IN}/${VAR}_${DOMAIN}_${EXP}_${FREQ}_*.nc ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc

    echo
    echo "Convert unit"
    if [ ${VAR} = 'pr'  ]
    then
    CDO -b f32 mulc,86400 ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_${FREQ}_${YR}.nc
    CDO yearsum ${VAR}_${DOMAIN}_RegCM5_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_year_${YR}.nc
    else
    CDO -b f32 subc,273.15 ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_${FREQ}_${YR}.nc
    CDO yearmean ${VAR}_${DOMAIN}_RegCM5_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_year_${YR}.nc
    fi

    echo
    echo "Compute trend"
    CDO trend ${VAR}_${DOMAIN}_RegCM5_year_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_year_${YR}_atrend.nc ${VAR}_${DOMAIN}_RegCM5_year_${YR}_btrend.nc

    echo 
    echo "Delete files"
    rm *_day_${YR}.nc

done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
