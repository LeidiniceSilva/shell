#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 15, 2024'
#__description__ = 'Posprocessing the dataset with CDO'
 
{

set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="SAM-25km"
DATASET="ERA5"
VAR_LIST="msl t u v"

DIR_IN="/marconi_work/ICT23_ESP/mdasilva/SAM-3km/post_cyclone/obs/era5"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"
    
echo
cd ${DIR_IN}
echo ${DIR_IN}

echo
echo "--------------- INIT POSPROCESSING DATASET ----------------"

for VAR in ${VAR_LIST[@]}; do
   
    echo
    echo "1. Regrid"
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_1hr_2018010100-2021123100.nc -34.5,-15,1.5 -76,-38.5,1.5 bil

done
    
echo
echo "--------------- THE END POSPROCESSING DATASET ----------------"

}
