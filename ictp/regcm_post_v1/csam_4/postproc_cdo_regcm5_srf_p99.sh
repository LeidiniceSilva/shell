#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Calculate the p99 of RegCM5 with CDO'
 
{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

VAR="pr"
EXP="CSAM-4"
DT="2018-2021"

DIR_PART1="/marconi/home/userexternal/mdasilva/user/mdasilva/${EXP}/ICTP-RegCM5/v0/day/${VAR}"
DIR_PART2="/marconi/home/userexternal/mdasilva/user/mdasilva/${EXP}/ICTP-RegCMICTP-RegCM5/v0/day/${VAR}"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/${EXP}/post_evaluate"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo 
echo "1. Concatenate data"
CDO mergetime ${DIR_PART1}/*2018*.nc ${VAR}_${EXP}_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_v0_day_2018.nc
CDO mergetime ${DIR_PART2}/*2019*.nc ${VAR}_${EXP}_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_v0_day_2019.nc
CDO mergetime ${DIR_PART2}/*2020*.nc ${VAR}_${EXP}_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_v0_day_2020.nc
CDO mergetime ${DIR_PART1}/*2021*.nc ${VAR}_${EXP}_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_v0_day_2021.nc
CDO mergetime ${VAR}_${EXP}_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_v0_day_*.nc ${VAR}_${EXP}_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_v0_day_${DT}.nc   

echo
echo "2. Convert unit"
CDO -b f32 mulc,86400 ${VAR}_${EXP}_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_v0_day_${DT}.nc ${VAR}_${EXP}_RegCM5_${DT}.nc

echo
echo "3. Calculate p99"
CDO timmin ${VAR}_${EXP}_RegCM5_${DT}.nc ${VAR}_${EXP}_RegCM5_${DT}_min.nc
CDO timmax ${VAR}_${EXP}_RegCM5_${DT}.nc ${VAR}_${EXP}_RegCM5_${DT}_max.nc
CDO timpctl,99 ${VAR}_${EXP}_RegCM5_${DT}.nc ${VAR}_${EXP}_RegCM5_${DT}_min.nc ${VAR}_${EXP}_RegCM5_${DT}_max.nc p99_${EXP}_RegCM5_${DT}.nc
  
echo
echo "5. Regrid variable"
${BIN}/./regrid p99_${EXP}_RegCM5_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo 
echo "7. Delete files"
rm ${VAR}_${EXP}_ECMWF-ERA5_evaluation_r1i1p1f1*
rm ${VAR}_${EXP}_RegCM5_${DT}.nc
rm ${VAR}_${EXP}_RegCM5_${DT}_min.nc 
rm ${VAR}_${EXP}_RegCM5_${DT}_max.nc 
rm p99_${EXP}_RegCM5_${DT}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
