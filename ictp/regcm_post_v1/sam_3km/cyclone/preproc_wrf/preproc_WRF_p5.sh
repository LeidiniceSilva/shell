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

VAR_LIST="PREC_ACC_NC U10e V10e"
EXP="SAM-3km"
FILE="ECMWF-ERA5_evaluation_r1i1p1f1_UCAR-WRF"
PATH_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/wrf/wrf/WRF"
DT="2018-2021"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do

    DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/wrf/wrf/${VAR}"
    
    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}
    
    for YEAR in `seq -w 2018 2021`; do
        for MON in `seq -w 01 12`; do

            ncremap -m ${PATH_IN}/WRF2SAM2_esmf_weights_bilinear.nc ${VAR}_wrf3d_ml_saag_${YEAR}${MON}.nc ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc

        done
    done
    
    CDO mergetime ${VAR}_${EXP}_${MODEL}_*.nc ${VAR}_${EXP}_${MODEL}_${DT}.nc

done

echo
echo "--------------- THE END POSPROCESSING MODEL -------------"

}


