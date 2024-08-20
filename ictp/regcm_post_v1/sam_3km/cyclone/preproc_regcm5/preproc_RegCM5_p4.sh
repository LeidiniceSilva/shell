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

VAR_LIST="psl tas uas vas" # cape psl tas uas vas
EXP="SAM-3km"
MODEL="RegCM5"
DT="2018-2021"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/output"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do

    DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/regcm5/regcm5/${VAR}"
    
    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}
    
    #for YEAR in `seq -w 2018 2021`; do
        #for MON in `seq -w 01 12`; do
	    
	    #CDO selname,${VAR} ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${MODEL}_1hr_${YEAR}${MON}0100.nc
	    
        #done
    #done
    
    CDO mergetime ${VAR}_${EXP}_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_1hr_*.nc  ${VAR}_${EXP}_${MODEL}_1hr_${DT}.nc
    CDO selhour,00,06,12,18 ${VAR}_${EXP}_${MODEL}_1hr_${DT}.nc ${VAR}_${EXP}_${MODEL}_6hr_${DT}.nc
    ${BIN}/./regrid ${VAR}_${EXP}_${MODEL}_6hr_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil	
    
done
    
echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
