#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 15, 2024'
#__description__ = 'Posprocessing the dataset with CDO'

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

# Change path
DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/obs/era5/era5"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/obs/era5/postproc"

# Set file name
VAR_LIST="msl u10 v10"
EXP="SAM-25km"
DATASET="ERA5"

# Datetime
ANO_I=2018
ANO_F=2021 

for VAR in ${VAR_LIST[@]}; do
    
    for YR in $(seq $ANO_I $ANO_F); do
        CDO selyear,$YR ${DIR_IN}/${VAR}_${EXP}_${DATASET}_1hr_2018010100-2021123100_smooth2.nc ${DIR_OUT}/${VAR}_${EXP}_${DATASET}_${YR}.nc
   	
	for HR in 00 06 12 18; do
            CDO selhour,$HR ${DIR_OUT}/${VAR}_${EXP}_${DATASET}_${YR}.nc ${DIR_OUT}/${VAR}.${YR}.${HR}.nc
	                
	done
    done
done

}


