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

VAR_LIST="U10 V10 PSFC"
MODEL="ECMWF-ERA5_evaluation_r1i1p1f1_UCAR-WRF"

BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/wrf/postproc"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    
    DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/wrf/wrf/${VAR}"
    
    echo
    cd ${DIR_IN}
    echo ${DIR_IN}
    
    for YEAR in `seq -w 2018 2021`; do
        for MON in `seq -w 01 12`; do
	    
	    echo
	    echo "2. Regrid"
	    ${BIN}/./regrid ${VAR}_${MODEL}_${YEAR}${MON}.nc -34.5,-15,1.5 -76,-38.5,1.5 bil

	    echo
	    echo "3. Smooth"
	    CDO smooth ${VAR}_${MODEL}_${YEAR}${MON}_lonlat.nc ${VAR}_${MODEL}_${YEAR}${MON}_smooth.nc
	    CDO smooth ${VAR}_${MODEL}_${YEAR}${MON}_smooth.nc ${DIR_OUT}/${VAR}_${MODEL}_${YEAR}${MON}_preproc.nc
	    	
        done
    done	
done
    
echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
