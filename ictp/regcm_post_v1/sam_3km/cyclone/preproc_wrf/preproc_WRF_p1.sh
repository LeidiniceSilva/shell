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

VAR_LIST="PSL U10e V10e"
EXP="SAM-3km"
MODEL="ECMWF-ERA5_evaluation_r1i1p1f1_UCAR-WRF"
DT="2018-2021"

DIR="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/wrf/wrf/WRF"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "1. Select variable"
for VAR in ${VAR_LIST[@]}; do
    
    DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/wrf/wrf/${VAR}"
    
    echo
    cd ${DIR_IN}
    echo ${DIR_IN}
    
    for YEAR in `seq -w 2018 2021`; do
        for MON in `seq -w 01 12`; do
	    
	    echo
	    echo "2. Regrid"
            if [ ${VAR} == "PSL" ]
	    then
	    	cp ${VAR}_wrf2d_ml_saag_${YEAR}${MON}.nc ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc
	    	${BIN}/./regrid ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc -34.5,-15,1.5 -76,-38.5,1.5 bil
	    else
	    	CDO -setgrid,${DIR}/xlonlat.nc ${VAR}_wrf2d_ml_saag_${YEAR}${MON}.nc ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc
	    	${BIN}/./regrid ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc -34.5,-15,1.5 -76,-38.5,1.5 bil
	    fi
	    
	    echo
	    echo "3. Smooth"
	    CDO smooth ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}_lonlat.nc ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}_smooth.nc
	    CDO smooth ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}_smooth.nc ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}_smooth2.nc
	    	
        done
    done	
    
    CDO mergetime ${VAR}_${EXP}_${MODEL}_*_smooth2.nc ${VAR}_${EXP}_${MODEL}_${DT}_smooth2.nc
    
done
    
echo
echo "--------------- THE END POSPROCESSING MODEL -------------"

}
