#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'May 28, 2024'
#__description__ = 'Posprocessing the WRF output with CDO'
 
{

set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

VAR_LIST="U10 V10 PREC_ACC_NC PSFC"
EXP="SAM-4km"
MODEL="ECMWF-ERA5_evaluation_r1i1p1f1_UCAR-WRF"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do

    DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/WRF/${VAR}"
    
    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}
    
    for YEAR in `seq -w 2018 2021`; do
        for MON in `seq -w 01 12`; do
	    
	    echo
	    echo "1. Select variable: ${VAR}"
	    CDO selname,${VAR} ${DIR_IN}/wrf2d_ml_saag_${YEAR}${MON}.nc ${VAR}_${MODEL}_${YEAR}${MON}.nc
	    
        done
    done	

done
    
echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
