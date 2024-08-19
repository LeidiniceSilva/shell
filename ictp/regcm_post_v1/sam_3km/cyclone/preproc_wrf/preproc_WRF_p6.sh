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

VAR_LIST="P PSFC TK Z" 
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/wrf/wrf/MSLP"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do

    DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/wrf/wrf/${VAR}"
    
    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}
    
    for YEAR in `seq -w 2018 2021`; do
        for MON in `seq -w 01 12`; do
	
	    if [ ${VAR} == "PSFC" ]
	    then
	    CDO selhour,00,06,12,18 ${DIR_IN}/${VAR}_wrf2d_ml_saag_${YEAR}${MON}.nc ${VAR}_wrf2d_${YEAR}${MON}.nc
	    else
	    CDO selhour,00,06,12,18 ${DIR_IN}/${VAR}_wrf3d_ml_saag_${YEAR}${MON}.nc ${VAR}_wrf3d_ml_saag_${YEAR}${MON}.nc
	    CDO sellevel,1,2 ${VAR}_wrf3d_ml_saag_${YEAR}${MON}.nc ${VAR}_wrf3d_${YEAR}${MON}.nc
	    fi
	
        done
    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL -------------"

}
