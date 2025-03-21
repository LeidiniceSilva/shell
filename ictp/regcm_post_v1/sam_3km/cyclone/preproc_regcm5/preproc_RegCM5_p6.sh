#!/bin/bash

#SBATCH -A ICT25_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 15, 2024'
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 
{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="SAM-3km"
MODEL="RegCM5"
DT="2018-2021"
VAR_LIST="CAPE CIN"

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/cyclone/regcm"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    
    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/output/CORDEX/CMIP6/DD/NONE/ICTP/NONE/none/NN/RegCM5-0/v1-r1/6hr/${VAR}"    
    CDO mergetime ${DIR_IN}/${VAR}_NONE_NONE_none_NN_ICTP_RegCM5-0_v1-r1_6hr_*.nc ${VAR}_${EXP}_${MODEL}_6hr_${DT}.nc
    ${BIN}/./regrid ${VAR}_${EXP}_${MODEL}_6hr_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil	
    
done
    
echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
