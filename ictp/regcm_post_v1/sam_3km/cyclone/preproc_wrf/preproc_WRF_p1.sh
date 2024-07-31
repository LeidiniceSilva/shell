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

VAR_LIST="PSFC U10e V10e"
EXP="SAM-3km"
MODEL="ECMWF-ERA5_evaluation_r1i1p1f1_UCAR-WRF"

DIR="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/wrf/wrf/WRF"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/wrf/postproc"

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
            if [ ${VAR} == "PSFC" ] || [ ${VAR} == "U10e" ] || [ ${VAR} == "V10e" ]
	    then
	    CDO -setgrid,${DIR}/xlonlat.nc ${VAR}_wrf2d_ml_saag_${YEAR}${MON}.nc ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc
	    else
	    CDO -setgrid,${DIR}/xlonlat.nc ${VAR}_wrf3d_ml_saag_${YEAR}${MON}.nc ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc
	    fi
	    
	    CDO remapbil,${DIR}/grid.txt ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}_lonlat.nc
	    	    
	    echo
	    echo "3. Smooth"
	    CDO smooth ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}_lonlat.nc ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}_smooth.nc
	    CDO smooth ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}_smooth.nc ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}_smooth2.nc
	    	
        done
    done	
done
    
echo
echo "--------------- THE END POSPROCESSING MODEL -------------"

}
