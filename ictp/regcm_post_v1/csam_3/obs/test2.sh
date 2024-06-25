#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 
{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="200101"
EXP="CSAM-3"
VAR="pr"

DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/CORDEX/post_evaluate/obs"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"
	
echo
echo "1. Calculate p99"
CDO timmin ${VAR}_${EXP}_ERA5_day_${YR}.nc ${VAR}_${EXP}_ERA5_day_${YR}_min.nc
CDO timmax ${VAR}_${EXP}_ERA5_day_${YR}.nc ${VAR}_${EXP}_ERA5_day_${YR}_max.nc
CDO timpctl,99 ${VAR}_${EXP}_ERA5_day_${YR}.nc ${VAR}_${EXP}_ERA5_day_${YR}_min.nc ${VAR}_${EXP}_ERA5_day_${YR}_max.nc p99_${EXP}_ERA5_day_${YR}.nc

echo
echo "2. Calculate Freq"
CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_ERA5_day_${YR}.nc ${VAR}_freq_${EXP}_ERA5_day_${YR}.nc

echo
echo "3. Calculate Int"
CDO histmean,1,100000 ${VAR}_${EXP}_ERA5_day_${YR}.nc ${VAR}_int_${EXP}_ERA5_day_${YR}.nc

echo
echo "4. Regrid variable"
${BIN}/./regrid p99_${EXP}_ERA5_day_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid ${VAR}_freq_${EXP}_ERA5_day_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid ${VAR}_int_${EXP}_ERA5_day_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
