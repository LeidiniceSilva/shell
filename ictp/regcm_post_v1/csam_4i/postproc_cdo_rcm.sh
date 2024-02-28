#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Feb 26, 2024'
#__description__ = 'Posprocessing the RCM output with CDO'
 
{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

VAR="pr"
EXP="CSAM-4i_ECMWF-ERA5_evaluation"
DT="2018-2021"
SEASON_LIST="DJF MAM JJA SON"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/CSAM-4i/RCM"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/CSAM-4i/post_evaluate"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo 
echo "1. Select data"
CDO seldate,2018-06-01,2021-05-31 ${DIR_IN}/reg_ictp/${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl1_v0_day_20180601-20211231.nc ${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl1_v0_day_${DT}.nc
CDO seldate,2018-06-01,2021-05-31 ${DIR_IN}/reg_ictp/${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl2_v0_day_20180601-20211231.nc ${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl2_v0_day_${DT}.nc
CDO seldate,2018-06-01,2021-05-31 ${DIR_IN}/reg_usp/${VAR}_${EXP}_r1i1p1f1_USP-RegCM471_v0_day_20180601_20211231.nc ${VAR}_${EXP}_r1i1p1f1_USP-RegCM471_v0_day_${DT}.nc
CDO seldate,2018-06-01,2021-05-31 ${DIR_IN}/wrf_ncar/${VAR}_${EXP}_r1i1p1f1_NCAR-WRF415_v1_day_20180101-20211231.nc ${VAR}_${EXP}_r1i1p1f1_NCAR-WRF415_v1_day_${DT}.nc
CDO seldate,2018-06-01,2021-05-31 ${DIR_IN}/wrf_ucan/${VAR}_${EXP}_r1i1p1f1_UCAN-WRF433_v1_day_20180601-20210531.nc ${VAR}_${EXP}_r1i1p1f1_UCAN-WRF433_v1_day_${DT}.nc

echo
echo "2. Convert unit"
CDO -b f32 mulc,86400 ${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl1_v0_day_${DT}.nc ${VAR}_${EXP}_ICTP-RegCM5pbl1_day_${DT}.nc
CDO -b f32 mulc,86400 ${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl2_v0_day_${DT}.nc ${VAR}_${EXP}_ICTP-RegCM5pbl2_day_${DT}.nc
CDO -b f32 mulc,86400 ${VAR}_${EXP}_r1i1p1f1_USP-RegCM471_v0_day_${DT}.nc ${VAR}_${EXP}_USP-RegCM471_day_${DT}.nc
CDO -b f32 mulc,86400 ${VAR}_${EXP}_r1i1p1f1_NCAR-WRF415_v1_day_${DT}.nc ${VAR}_${EXP}_NCAR-WRF415_day_${DT}.nc
CDO -b f32 mulc,86400 ${VAR}_${EXP}_r1i1p1f1_UCAN-WRF433_v1_day_${DT}.nc ${VAR}_${EXP}_UCAN-WRF433_day_${DT}.nc

echo
echo "3. Regrid output"
${BIN}/./regrid ${VAR}_${EXP}_ICTP-RegCM5pbl1_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid ${VAR}_${EXP}_ICTP-RegCM5pbl2_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid ${VAR}_${EXP}_USP-RegCM471_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid ${VAR}_${EXP}_NCAR-WRF415_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid ${VAR}_${EXP}_UCAN-WRF433_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
           
echo
echo "4. Calculate monthly avg"
CDO monmean ${VAR}_${EXP}_ICTP-RegCM5pbl1_day_${DT}_lonlat.nc ${VAR}_${EXP}_ICTP-RegCM5pbl1_mon_${DT}_lonlat.nc
CDO monmean ${VAR}_${EXP}_ICTP-RegCM5pbl2_day_${DT}_lonlat.nc ${VAR}_${EXP}_ICTP-RegCM5pbl2_mon_${DT}_lonlat.nc
CDO monmean ${VAR}_${EXP}_USP-RegCM471_day_${DT}_lonlat.nc ${VAR}_${EXP}_USP-RegCM471_mon_${DT}_lonlat.nc
CDO monmean ${VAR}_${EXP}_NCAR-WRF415_day_${DT}_lonlat.nc ${VAR}_${EXP}_NCAR-WRF415_mon_${DT}_lonlat.nc
CDO monmean ${VAR}_${EXP}_UCAN-WRF433_day_${DT}_lonlat.nc ${VAR}_${EXP}_UCAN-WRF433_mon_${DT}_lonlat.nc

echo
echo "5. Seasonal avg"
for SEASON in ${SEASON_LIST[@]}; do
    CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_ICTP-RegCM5pbl1_mon_${DT}_lonlat.nc ${VAR}_${EXP}_ICTP-RegCM5pbl1_${SEASON}_${DT}_lonlat.nc
    CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_ICTP-RegCM5pbl2_mon_${DT}_lonlat.nc ${VAR}_${EXP}_ICTP-RegCM5pbl2_${SEASON}_${DT}_lonlat.nc
    CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_USP-RegCM471_mon_${DT}_lonlat.nc ${VAR}_${EXP}_USP-RegCM471_${SEASON}_${DT}_lonlat.nc
    CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_NCAR-WRF415_mon_${DT}_lonlat.nc ${VAR}_${EXP}_NCAR-WRF415_${SEASON}_${DT}_lonlat.nc
    CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_UCAN-WRF433_mon_${DT}_lonlat.nc ${VAR}_${EXP}_UCAN-WRF433_${SEASON}_${DT}_lonlat.nc
done

echo 
echo "6. Delete files"
rm ${VAR}_${EXP}_*_${DT}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
