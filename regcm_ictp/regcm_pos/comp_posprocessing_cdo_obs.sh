#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the OBS datasets with CDO'
 
DATASET="CPC"

DT="2018-2021"
DT_i="2018-01-01"
DT_ii="2021-12-31"

DIR_IN="/marconi/home/userexternal/mdasilva/OBS"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/sam_3km/postproc"

REGRIG="/marconi/home/userexternal/mdasilva/github_projects/shell/regcm_ictp/regcm_pos"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

if [ ${DATASET} == 'CPC' ]
then
echo 
echo "1. ------------------------------- PROCCESSING CPC DATASET -------------------------------"

echo
echo "1.1. Select date"
cdo seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/cpc.day.1979-2021.nc precip_SAM-3km_cpc_day_${DT}.nc
cdo seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/tmax.1979-2021.nc tmax_SAM-3km_cpc_day_${DT}.nc
cdo seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/tmin.1979-2021.nc tmin_SAM-3km_cpc_day_${DT}.nc

echo 
echo "1.2. Regrid output"
${REGRIG}/./regrid precip_SAM-3km_cpc_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${REGRIG}/./regrid tmax_SAM-3km_cpc_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${REGRIG}/./regrid tmin_SAM-3km_cpc_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
	
echo 
echo "1.3. Delete files"
rm *_SAM-3km_cpc_day_${DT}.nc

elif [ ${DATASET} == 'CRU' ]
then
echo 
echo "2.  ------------------------------- PROCCESSING CRU DATASET -------------------------------"

echo
echo "2.1. Select date"
cdo seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/cld.dat.nc cld_cru_ts4.07_mon_${DT}.nc
cdo seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/pre.dat.nc pre_cru_ts4.07_mon_${DT}.nc
cdo seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/tmp.dat.nc tmp_cru_ts4.07_mon_${DT}.nc
cdo seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/tmx.dat.nc tmx_cru_ts4.07_mon_${DT}.nc
cdo seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/tmn.dat.nc tmn_cru_ts4.07_mon_${DT}.nc

echo 
echo "2.2. Convert unit"
cdo divc,30.5 pre_cru_ts4.07_mon_${DT}.nc pre_SAM-3km_cru_ts4.07_mon_${DT}.nc
cp cld_cru_ts4.07_mon_${DT}.nc cld_SAM-3km_cru_ts4.07_mon_${DT}.nc
cp tmp_cru_ts4.07_mon_${DT}.nc tmp_SAM-3km_cru_ts4.07_mon_${DT}.nc
cp tmx_cru_ts4.07_mon_${DT}.nc tmx_SAM-3km_cru_ts4.07_mon_${DT}.nc
cp tmn_cru_ts4.07_mon_${DT}.nc tmn_SAM-3km_cru_ts4.07_mon_${DT}.nc

echo 
echo "2.3. Regrid output"
${REGRIG}/./regrid cld_SAM-3km_cru_ts4.07_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${REGRIG}/./regrid pre_SAM-3km_cru_ts4.07_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${REGRIG}/./regrid tmp_SAM-3km_cru_ts4.07_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${REGRIG}/./regrid tmx_SAM-3km_cru_ts4.07_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${REGRIG}/./regrid tmn_SAM-3km_cru_ts4.07_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo 
echo "2.4. Delete files"
rm *_cru_ts4.07_mon_${DT}.nc
rm *_SAM-3km_cru_ts4.07_mon_${DT}.nc

else
echo 
echo "3. ------------------------------- PROCCESSING GPCP DATASET -------------------------------"

echo
echo "3.1. Select date"
cdo seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/GPCPMON_L3_198301-202209_V3.2.nc4 GPCP_SAM-3km_L3_V3.2_mon_${DT}.nc

echo 
echo "3.2. Select variable"
cdo selvar,sat_gauge_precip GPCP_L3_V3.2_mon_${DT}.nc sat_gauge_precip_SAM-3km_GPCP_L3_V3.2_mon_${DT}.nc

echo 
echo "2.3. Regrid output"
${REGRIG}/./regrid sat_gauge_precip_SAM-3km_GPCP_L3_V3.2_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo 
echo "3.4. Delete files"
rm *_SAM-3km_L3_V3.2_mon_${DT}.nc

fi
