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
#__date__        = 'May 28, 2024'
#__description__ = 'Posprocessing the WRF output with CDO'

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

VAR_LIST="PREC_ACC_NC"

BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    
    DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/wrf/wrf/${VAR}"
    
    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}
    
    CDO mergetime PREC_ACC_NC_ECMWF-ERA5_evaluation_r1i1p1f1_UCAR-WRF_*.nc PREC_ACC_NC_SAM-3km_WRF415_1hr_2018-2021.nc
    ${BIN}/./regrid PREC_ACC_NC_SAM-3km_WRF415_1hr_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

done
    
echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
