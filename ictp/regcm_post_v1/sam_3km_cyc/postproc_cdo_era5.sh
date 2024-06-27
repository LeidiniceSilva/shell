#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jan 02, 2024'
#__description__ = 'Posprocessing the OBS with CDO'

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="SAM-3km-cyclone"
DT="2023060100-2023073100"
VAR_LIST="mslhf msl msshf pr q t2m t u10 u v10 v w z"

DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km-cyclone/post/obs/era5"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING OBS ----------------"

for VAR in ${VAR_LIST[@]}; do
       
    ${BIN}/./regrid ${VAR}_SAM-25km_era5_1hr_${DT}.nc -48.42226,-10.53818,0.03 -81.08339,-33.17916,0.03 bil
    mv ${VAR}_SAM-25km_era5_1hr_${DT}_lonlat.nc ${VAR}_${EXP}_ERA5_1hr_${DT}_lonlat.nc
    
done

echo
echo "--------------- THE END POSPROCESSING OBS ----------------"

}
