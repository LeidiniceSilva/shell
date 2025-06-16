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
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 
{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

FREQ="day"
DOMAIN="CSAM-3"
EXP="ERA5_evaluation_r1i1p1f1_ICTP_RegCM5"
VAR_LIST="hus200 hus850 ua200 ua850 va200 va850"

YR="2000-2001"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/rcm"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"
	
for VAR in ${VAR_LIST[@]}; do

    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/ERA5/ERA5-CSAM-3/CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5/v1-r1/${FREQ}/${VAR}"

    echo
    echo "Select variable"
    CDO mergetime ${DIR_IN}/${VAR}_${DOMAIN}_${EXP}_0_${FREQ}_*.nc ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc
    
    echo
    echo "Monthly average"
    CDO monmean ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc

    echo
    echo "Seasonal avg and regrid"
    for SEASON in ${SEASON_LIST[@]}; do
        
	CDO -timmean -selseas,${SEASON} ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_${SEASON}_${YR}.nc
	${BIN}/./regrid ${VAR}_${DOMAIN}_RegCM5_${SEASON}_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

    done
    
    echo 
    echo "Delete files"
    rm ${VAR}_${DOMAIN}_*_${YR}.nc
      
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
