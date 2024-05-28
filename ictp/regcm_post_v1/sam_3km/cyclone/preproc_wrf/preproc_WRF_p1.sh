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

VAR_LIST="U10 V10 PREC_ACC_NC PSFC"
FILE="ECMWF-ERA5_evaluation_r1i1p1f1_UCAR-WRF"
PATH="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/rcm_ii/wrf"

for VAR in ${VAR_LIST[@]}; do
	for YEAR in `seq -w 2018 2021`; do
		for HOUR in 00 06 12 18; do
		
			CDO selhour,$HR ${PATH}/${VAR}/${VAR}_${MODEL}_${YEAR}${MON}_preproc.nc ${path}/postproc/${VAR}.${YEAR}.${HOUR}.nc
	             
	done
    done
done

}


