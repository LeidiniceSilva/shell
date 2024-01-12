#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the OBS datasets with CDO'

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DATASET="ERA5"

EXP="SAM-3km"
DT="2018-2021"
DT_i="2018-01-01"
DT_ii="2021-12-31"
SEASON_LIST="DJF MAM JJA SON"

DIR_IN="/marconi/home/userexternal/mdasilva/OBS"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/sam_3km/post"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}


if [ ${DATASET} == 'CPC' ]
then
echo 
echo "1. ------------------------------- PROCCESSING CPC DATASET -------------------------------"

echo
echo "1.1. Select date"
CDO seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/cpc.day.1979-2021.nc precip_${EXP}_${DATASET}_day_${DT}.nc
CDO seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/tmax.1979-2021.nc tmax_${EXP}_${DATASET}_day_${DT}.nc
CDO seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/tmin.1979-2021.nc tmin_${EXP}_${DATASET}_day_${DT}.nc

echo "1.2. Monthly avg"
CDO monmean precip_${EXP}_${DATASET}_day_${DT}.nc precip_${EXP}_${DATASET}_mon_${DT}.nc
CDO monmean tmax_${EXP}_${DATASET}_day_${DT}.nc tmax_${EXP}_${DATASET}_mon_${DT}.nc
CDO monmean tmin_${EXP}_${DATASET}_day_${DT}.nc tmin_${EXP}_${DATASET}_mon_${DT}.nc

echo 
echo "1.3. Regrid output"
${BIN}/./regrid precip_${EXP}_${DATASET}_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid precip_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid tmax_${EXP}_${DATASET}_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid tmax_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid tmin_${EXP}_${DATASET}_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid tmin_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo
echo "1.4. Seasonal avg"
for SEASON in ${SEASON_LIST[@]}; do
    CDO -timmean -selseas,${SEASON} precip_${EXP}_${DATASET}_mon_${DT}_lonlat.nc precip_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
    CDO -timmean -selseas,${SEASON} tmax_${EXP}_${DATASET}_mon_${DT}_lonlat.nc precip_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
    CDO -timmean -selseas,${SEASON} tmin_${EXP}_${DATASET}_mon_${DT}_lonlat.nc precip_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
done
         
echo 
echo "1.5. Delete files"
rm *_${EXP}_${DATASET}_*_${DT}.nc


elif [ ${DATASET} == 'CRU' ]
then
echo 
echo "2.  ------------------------------- PROCCESSING CRU DATASET -------------------------------"

echo
echo "2.1. Select date"
CDO seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/pre.dat.nc pre_${DATASET}_mon_${DT}.nc
CDO seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/tmp.dat.nc tmp_${DATASET}_mon_${DT}.nc
CDO seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/tmx.dat.nc tmx_${DATASET}_mon_${DT}.nc
CDO seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/tmn.dat.nc tmn_${DATASET}_mon_${DT}.nc
CDO seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/cld.dat.nc cld_${DATASET}_mon_${DT}.nc

echo 
echo "2.2. Convert unit"
CDO -b f32 divc,30.5 pre_${DATASET}_mon_${DT}.nc pre_${EXP}_${DATASET}_mon_${DT}.nc
cp tmp_${DATASET}_mon_${DT}.nc tmp_${EXP}_${DATASET}_mon_${DT}.nc
cp tmx_${DATASET}_mon_${DT}.nc tmx_${EXP}_${DATASET}_mon_${DT}.nc
cp tmn_${DATASET}_mon_${DT}.nc tmn_${EXP}_${DATASET}_mon_${DT}.nc
cp cld_${DATASET}_mon_${DT}.nc cld_${EXP}_${DATASET}_mon_${DT}.nc

echo 
echo "2.3. Regrid output"
${BIN}/./regrid pre_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid tmp_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid tmx_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid tmn_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid cld_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo
echo "2.4. Seasonal avg"
for SEASON in ${SEASON_LIST[@]}; do
    CDO -timmean -selseas,${SEASON} pre_${EXP}_${DATASET}_mon_${DT}_lonlat.nc pre_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
    CDO -timmean -selseas,${SEASON} tmp_${EXP}_${DATASET}_mon_${DT}_lonlat.nc tmp_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
    CDO -timmean -selseas,${SEASON} tmx_${EXP}_${DATASET}_mon_${DT}_lonlat.nc tmx_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
    CDO -timmean -selseas,${SEASON} tmn_${EXP}_${DATASET}_mon_${DT}_lonlat.nc tmn_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
    CDO -timmean -selseas,${SEASON} cld_${EXP}_${DATASET}_mon_${DT}_lonlat.nc cld_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
done

echo 
echo "2.5. Delete files"
rm *_${DATASET}_mon_${DT}.nc


elif [ ${DATASET} == 'ERA5' ]
then
echo 
echo "3.  ------------------------------- PROCCESSING ERA5 DATASET -------------------------------"

echo
echo "3.1. Convert unit"
cdo -b f32 mulc,1000 ${DIR_IN}/${DATASET}/tp_${DATASET}_${DT}.nc tp_${DATASET}_day_${DT}.nc
cdo -b f32 subc,273.15 ${DIR_IN}/${DATASET}/t2m_${DATASET}_${DT}.nc t2m_${DATASET}_mon_${DT}.nc
cdo -b f32 subc,273.15 ${DIR_IN}/${DATASET}/mx2t_${DATASET}_${DT}.nc mx2t_${DATASET}_mon_${DT}.nc
cdo -b f32 subc,273.15 ${DIR_IN}/${DATASET}/mn2t_${DATASET}_${DT}.nc mn2t_${DATASET}_mon_${DT}.nc
cdo -b f32 mulc,100 ${DIR_IN}/${DATASET}/tcc_${DATASET}_${DT}.nc tcc_${DATASET}_mon_${DT}.nc

echo 
echo "3.2. Calculate monthly mean"
cdo monmean tp_${DATASET}_day_${DT}.nc tp_${DATASET}_mon_${DT}.nc

echo 
echo "3.3. Change names"
cp tp_${DATASET}_day_${DT}.nc tp_${EXP}_${DATASET}_day_${DT}.nc
cp tp_${DATASET}_mon_${DT}.nc tp_${EXP}_${DATASET}_mon_${DT}.nc 
cp t2m_${DATASET}_mon_${DT}.nc t2m_${EXP}_${DATASET}_mon_${DT}.nc
cp mx2t_${DATASET}_mon_${DT}.nc mx2t_${EXP}_${DATASET}_mon_${DT}.nc
cp mn2t_${DATASET}_mon_${DT}.nc mn2t_${EXP}_${DATASET}_mon_${DT}.nc
cp tcc_${DATASET}_mon_${DT}.nc tcc_${EXP}_${DATASET}_mon_${DT}.nc
cp ${DIR_IN}/${DATASET}/cc_${DATASET}_${DT}.nc cc_${EXP}_${DATASET}_mon_${DT}.nc
cp ${DIR_IN}/${DATASET}/ciwc_${DATASET}_${DT}.nc ciwc_${EXP}_${DATASET}_mon_${DT}.nc
cp ${DIR_IN}/${DATASET}/clwc_${DATASET}_${DT}.nc clwc_${EXP}_${DATASET}_mon_${DT}.nc
cp ${DIR_IN}/${DATASET}/q_${DATASET}_${DT}.nc q_${EXP}_${DATASET}_mon_${DT}.nc
cp ${DIR_IN}/${DATASET}/u_${DATASET}_${DT}.nc u_${EXP}_${DATASET}_mon_${DT}.nc
cp ${DIR_IN}/${DATASET}/v_${DATASET}_${DT}.nc v_${EXP}_${DATASET}_mon_${DT}.nc

echo 
echo "3.4. Regrid output"
${BIN}/./regrid tp_${EXP}_${DATASET}_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid tp_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid t2m_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid mx2t_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid mn2t_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid tcc_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid cc_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid ciwc_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid clwc_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid q_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid u_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid v_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
  
echo
echo "3.5. Seasonal avg"
for SEASON in ${SEASON_LIST[@]}; do
    CDO -timmean -selseas,${SEASON} tp_${EXP}_${DATASET}_mon_${DT}_lonlat.nc tp_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
    CDO -timmean -selseas,${SEASON} t2m_${EXP}_${DATASET}_mon_${DT}_lonlat.nc t2m_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
    CDO -timmean -selseas,${SEASON} mx2t_${EXP}_${DATASET}_mon_${DT}_lonlat.nc mx2t_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
    CDO -timmean -selseas,${SEASON} mn2t_${EXP}_${DATASET}_mon_${DT}_lonlat.nc mn2t_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
    CDO -timmean -selseas,${SEASON} tcc_${EXP}_${DATASET}_mon_${DT}_lonlat.nc tcc_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
    CDO -timmean -selseas,${SEASON} cc_${EXP}_${DATASET}_mon_${DT}_lonlat.nc cc_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
    CDO -timmean -selseas,${SEASON} ciwc_${EXP}_${DATASET}_mon_${DT}_lonlat.nc ciwc_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
    CDO -timmean -selseas,${SEASON} clwc_${EXP}_${DATASET}_mon_${DT}_lonlat.nc clwc_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
    CDO -timmean -selseas,${SEASON} q_${EXP}_${DATASET}_mon_${DT}_lonlat.nc q_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
    CDO -timmean -selseas,${SEASON} u_${EXP}_${DATASET}_mon_${DT}_lonlat.nc u_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
    CDO -timmean -selseas,${SEASON} v_${EXP}_${DATASET}_mon_${DT}_lonlat.nc v_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
done

echo
echo "3.6. Select levels"
VAR_LIST="q u v"
for VAR in ${VAR_LIST[@]}; do
    CDO sellevel,200 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_200hPa_${EXP}_${DATASET}_DJF_${DT}_lonlat.nc
    CDO sellevel,500 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_500hPa_${EXP}_${DATASET}_DJF_${DT}_lonlat.nc
    CDO sellevel,850 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_850hPa_${EXP}_${DATASET}_DJF_${DT}_lonlat.nc
    CDO sellevel,200 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_200hPa_${EXP}_${DATASET}_MAM_${DT}_lonlat.nc
    CDO sellevel,500 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_500hPa_${EXP}_${DATASET}_MAM_${DT}_lonlat.nc
    CDO sellevel,850 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_850hPa_${EXP}_${DATASET}_MAM_${DT}_lonlat.nc
    CDO sellevel,200 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_200hPa_${EXP}_${DATASET}_JJA_${DT}_lonlat.nc
    CDO sellevel,500 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_500hPa_${EXP}_${DATASET}_JJA_${DT}_lonlat.nc
    CDO sellevel,850 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_850hPa_${EXP}_${DATASET}_JJA_${DT}_lonlat.nc
    CDO sellevel,200 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_200hPa_${EXP}_${DATASET}_SON_${DT}_lonlat.nc
    CDO sellevel,500 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_500hPa_${EXP}_${DATASET}_SON_${DT}_lonlat.nc
    CDO sellevel,850 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_850hPa_${EXP}_${DATASET}_SON_${DT}_lonlat.nc
done

echo 
echo "3.7. Delete files"
rm *_${DATASET}_day_${DT}.nc
rm *_${DATASET}_mon_${DT}.nc

else
echo 
echo "4. ------------------------------- PROCCESSING GPCP DATASET -------------------------------"

echo
echo "4.1. Select date"
cdo seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/GPCPMON_L3_198301-202209_V3.2.nc4 ${EXP}_${DATASET}_mon_${DT}.nc

echo 
echo "4.2. Select variable"
cdo selvar,sat_gauge_precip ${EXP}_${DATASET}_mon_${DT}.nc sat_gauge_precip_${EXP}_${DATASET}_mon_${DT}.nc

echo 
echo "4.3. Regrid output"
${BIN}/./regrid sat_gauge_precip_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo
echo "4.4. Seasonal avg"
for SEASON in ${SEASON_LIST[@]}; do
    CDO -timmean -selseas,${SEASON} sat_gauge_precip_${EXP}_${DATASET}_mon_${DT}_lonlat.nc sat_gauge_precip_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
done

echo 
echo "4.5. Delete files"
rm *${DATASET}_mon_${DT}.nc

fi

}
