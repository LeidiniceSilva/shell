#!/bin/bash
 
#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'May 28, 2024'
#__description__ = 'Preprocess WRF output to track cyclone'

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

# Change path
DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/wrf/wrf"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/wrf/postproc"

# Set file name
VAR_LIST="PSFC U V"
EXP="SAM-3km"
MODEL="ECMWF-ERA5_evaluation_r1i1p1f1_UCAR-WRF"
DT="2018010100-2021123100"

# Datetime
ANO_I=2018
ANO_F=2021 

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do

    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}
    
    for YR in `seq -w 2018 2021`; do
        CDO selyear,$YR ${DIR_IN}/${VAR}/${VAR}_${EXP}_${MODEL}_${DT}_smooth2.nc ${VAR}_${EXP}_${MODEL}_${YR}.nc
   	
	for HR in 00 06 12 18; do
            CDO selhour,$HR ${VAR}_${EXP}_${MODEL}_${YR}.nc ${VAR}.${YR}.${HR}.nc
	                
	done
    done
done
    
echo
echo "--------------- THE END POSPROCESSING MODEL -------------"

}
