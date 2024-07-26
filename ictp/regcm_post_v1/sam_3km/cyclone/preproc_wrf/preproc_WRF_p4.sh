#!/bin/bash
 
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

VAR_LIST="U V"
PATH_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/wrf/wrf"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do

    DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/wrf/wrf/${VAR}"
    
    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}
    
    for YEAR in `seq -w 2018 2021`; do
        for MON in `seq -w 01 12`; do

            cdo selvar,${VAR} ${PATH_IN}/WRF/wind_925Pha_ml_saag_${YEAR}${MON}.nc ${VAR}_wrf3d_ml_saag_${YEAR}${MON}.nc

        done
    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL -------------"

}
