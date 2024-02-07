#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jan 31, 2024'
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 
{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

VAR="tasmin"
EXP="CSAM-4"
DT="2018-2021"
SEASON_LIST="DJF MAM JJA SON"
VAR_list="pr tas tasmax tasmin"

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
CDO mergetime ${DIR_PART2}/*2019*.nc ${VAR}_${EXP}_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCMICTP-RegCM5_v0_day_2019.nc
CDO mergetime ${DIR_PART2}/*2020*.nc ${VAR}_${EXP}_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCMICTP-RegCM5_v0_day_2020.nc
CDO mergetime ${DIR_PART1}/*2021*.nc ${VAR}_${EXP}_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_v0_day_2021.nc
CDO mergetime ${VAR}_${EXP}_*.nc ${VAR}_${EXP}_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_v0_day_${DT}.nc   

echo
echo "2. Convert unit"
if [ ${VAR} = pr  ]
then
CDO -b f32 mulc,86400 ${VAR}_${EXP}_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_v0_day_${DT}.nc ${VAR}_${EXP}_RegCM5_day_${DT}.nc
elif [ ${VAR} = tas  ]
then
CDO -b f32 subc,273.15 ${VAR}_${EXP}_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_v0_day_${DT}.nc ${VAR}_${EXP}_RegCM5_day_${DT}.nc
elif [ ${VAR} = tasmax  ]
then
CDO -b f32 subc,273.15 ${VAR}_${EXP}_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_v0_day_${DT}.nc ${VAR}_${EXP}_RegCM5_day_${DT}.nc
elif [ ${VAR} = tasmin  ]
then
CDO -b f32 subc,273.15 ${VAR}_${EXP}_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_v0_day_${DT}.nc ${VAR}_${EXP}_RegCM5_day_${DT}.nc
else
cp ${VAR}_${EXP}_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_v0_day_${DT}.nc ${VAR}_${EXP}_RegCM5_day_${DT}.nc
fi

echo
echo "3. Regrid output"
${BIN}/./regrid ${VAR}_${EXP}_RegCM5_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
           
echo
echo "4. Calculate monthly avg"
CDO monmean ${VAR}_${EXP}_RegCM5_day_${DT}_lonlat.nc ${VAR}_${EXP}_RegCM5_mon_${DT}_lonlat.nc
    
echo
echo "5. Select subdomain"
CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_RegCM5_day_${DT}_lonlat.nc ${VAR}_SESA-4_RegCM5_day_${DT}_lonlat.nc
CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_RegCM5_mon_${DT}_lonlat.nc ${VAR}_SESA-4_RegCM5_mon_${DT}_lonlat.nc
 
echo
echo "6. Seasonal avg"
for SEASON in ${SEASON_LIST[@]}; do
    CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_RegCM5_mon_${DT}_lonlat.nc ${VAR}_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc
done

echo 
echo "7. Delete files"
rm ${VAR}_${EXP}_ECMWF-ERA5_evaluation_r1i1p1f1*
rm ${VAR}_${EXP}_RegCM5_day_${DT}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
