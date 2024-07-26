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

EXP="SAM-25km"
DATASET="ERA5"
VAR_LIST="msl u v"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/obs/era5/era5"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"
    
echo
cd ${DIR_IN}
echo ${DIR_IN}

echo
echo "--------------- INIT POSPROCESSING DATASET ----------------"

for VAR in ${VAR_LIST[@]}; do
   
    echo
    echo "1. Regrid and smooth"
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_1hr_2018010100-2021123100.nc -34.5,-15,1.5 -76,-38.5,1.5 bil
    CDO smooth ${VAR}_${EXP}_${DATASET}_1hr_2018010100-2021123100_lonlat.nc ${VAR}_${EXP}_${DATASET}_1hr_2018010100-2021123100_smooth.nc
    CDO smooth ${VAR}_${EXP}_${DATASET}_1hr_2018010100-2021123100_smooth.nc ${VAR}_${EXP}_${DATASET}_1hr_2018010100-2021123100_smooth2.nc

done
    
echo
echo "--------------- THE END POSPROCESSING DATASET ----------------"

}
