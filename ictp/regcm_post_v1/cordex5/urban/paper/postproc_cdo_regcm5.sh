#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jul 28, 2026'
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 
{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP=$1
DOMAIN="CSAM-3"

FREQ="day"
YR="2000-2009"

VAR_LIST="pr tasmax tasmin"

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/urban/paper"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "Select variable"
for VAR in ${VAR_LIST[@]}; do

    if [ ${EXP} == 'CTRL' ]; then
    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/pycordexer/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/${FREQ}/${VAR}"
    else
    DIR_IN="/leonardo/home/userexternal/ggiulian/scratch/urban/output/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/${FREQ}/${VAR}"
    fi

    echo
    echo "Merge files"
    CDO mergetime ${DIR_IN}/${VAR}_${DOMAIN}_ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1_${FREQ}_200*.nc ${VAR}_${DOMAIN}_${FREQ}_${YR}.nc

    echo
    echo "Convert unit"
    if [ ${VAR} == 'pr' ]; then
    CDO -b f32 mulc,86400 ${VAR}_${DOMAIN}_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5-ERA5_${EXP}_${FREQ}_${YR}_TMP.nc
    ncatted -O -a units,${VAR},m,c,mm/day ${VAR}_${DOMAIN}_RegCM5-ERA5_${EXP}_${FREQ}_${YR}_TMP.nc ${VAR}_${DOMAIN}_RegCM5-ERA5_${EXP}_${FREQ}_${YR}.nc 
    elif [ ${VAR} = 'tasmax' ] || [ ${VAR} = 'tasmin' ]; then
    CDO -b f32 subc,273.15 ${VAR}_${DOMAIN}_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5-ERA5_${EXP}_${FREQ}_${YR}_TMP.nc
    ncatted -O -a units,${VAR},m,c,Celsius ${VAR}_${DOMAIN}_RegCM5-ERA5_${EXP}_${FREQ}_${YR}_TMP.nc ${VAR}_${DOMAIN}_RegCM5-ERA5_${EXP}_${FREQ}_${YR}.nc 
    else
    mv ${VAR}_${DOMAIN}_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5-ERA5_${EXP}_${FREQ}_${YR}.nc
    fi
 
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
