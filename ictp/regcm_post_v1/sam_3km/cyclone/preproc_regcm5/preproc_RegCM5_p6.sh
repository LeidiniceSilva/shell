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
#__date__        = 'Mar 15, 2024'
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 
{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

VAR_LIST="CAPE CIN"
EXP="SAM-3km"
MODEL="RegCM5"
DT="2018-2021"

BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    
    DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/output/CORDEX/CMIP6/DD/NONE/ICTP/NONE/none/NN/RegCM5-0/v1-r1/6hr/${VAR}"
    DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/regcm5/regcm5/${VAR}"
    
    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}
    
    CDO mergetime ${DIR_IN}/${VAR}_NONE_NONE_none_NN_ICTP_RegCM5-0_v1-r1_6hr_*.nc ${VAR}_${EXP}_${MODEL}_6hr_${DT}.nc
    ${BIN}/./regrid ${VAR}_${EXP}_${MODEL}_6hr_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil	
    
done
    
echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
