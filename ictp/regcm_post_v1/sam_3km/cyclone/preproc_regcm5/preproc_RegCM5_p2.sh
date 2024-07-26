#!/bin/bash
 
#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 15, 2024'
#__description__ = 'Preprocess RegCM5 output to track cyclone'

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

VAR_LIST="psl ua va"
EXP="SAM-3km"
MODEL="ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5"
DT="2018010100-2021123100"

ANO_I=2018
ANO_F=2021 

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/regcm5"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do 
    
    for YR in $(seq $ANO_I $ANO_F); do
        if [ ${VAR} == 'psl' ]
	then
        CDO selyear,$YR ${DIR_IN}/regcm5/${VAR}/${VAR}_${EXP}_${MODEL}_1hr_${DT}_smooth2.nc ${DIR_IN}/postproc/${VAR}_${EXP}_${MODEL}_${YR}.nc 
	else
        CDO selyear,$YR ${DIR_IN}/regcm5/${VAR}/${VAR}_${EXP}_${MODEL}_6hr_${DT}_smooth2.nc ${DIR_IN}/postproc/${VAR}_${EXP}_${MODEL}_${YR}.nc 
	fi
	
	for HR in 00 06 12 18; do
            CDO selhour,$HR ${DIR_IN}/postproc/${VAR}_${EXP}_${MODEL}_${YR}.nc ${DIR_IN}/postproc/${VAR}.${YR}.${HR}.nc
	                
	done
    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
