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
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 
{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="2000-2000"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

FREQ="day"
DOMAIN="CSAM-3"
EXP="ERA5_evaluation_r1i1p1f1_ICTP_RegCM5"
#VAR_LIST="CAPE CIN pr tas tasmax tasmin clt rsnl"
VAR_LIST="CAPE CIN"

DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/CORDEX/post_evaluate/rcm"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"
	
for VAR in ${VAR_LIST[@]}; do

    DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/CORDEX/ERA5/ERA5-CSAM-3/CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5/0/${FREQ}/${VAR}"

    echo
    echo "1. Select variable"
    CDO mergetime ${DIR_IN}/${VAR}_${DOMAIN}_${EXP}_0_${FREQ}_*.nc ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc
    
    echo
    echo "2. Convert unit"
    if [ ${VAR} = 'pr'  ]
    then
    CDO -b f32 mulc,86400 ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}_unit.nc
    CDO monmean ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}_unit.nc ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc
    elif [ ${VAR} = 'tas' ] || [ ${VAR} = 'tasmax'  ] || [ ${VAR} = 'tasmin'  ]
    then
    CDO -b f32 subc,273.15 ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}_unit.nc
    CDO monmean ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}_unit.nc ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc
    else
    CDO monmean ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc
    fi

    echo
    echo "3. Seasonal avg and regrid"
    for SEASON in ${SEASON_LIST[@]}; do
        
	CDO -timmean -selseas,${SEASON} ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_${SEASON}_${YR}.nc
	${BIN}/./regrid ${VAR}_${DOMAIN}_RegCM5_${SEASON}_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

    done
    
    echo 
    echo "4. Delete files"
    rm ${VAR}_${DOMAIN}_${EXP}_${FREQ}_*.nc
    rm ${VAR}_${DOMAIN}_*_${YR}.nc
      
done


echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
