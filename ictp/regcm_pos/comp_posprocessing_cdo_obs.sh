#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the OBS datasets with CDO'
 
DATASET="ERA5"

EXP='SAM-3km'

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
cdo seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/cpc.day.1979-2021.nc precip_${EXP}_${DATASET}_day_${DT}.nc
cdo seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/tmax.1979-2021.nc tmax_${EXP}_${DATASET}_day_${DT}.nc
cdo seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/tmin.1979-2021.nc tmin_${EXP}_${DATASET}_day_${DT}.nc

echo 
echo "1.2. Regrid output"
${REGRIG}/./regrid precip_${EXP}_${DATASET}_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${REGRIG}/./regrid tmax_${EXP}_${DATASET}_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${REGRIG}/./regrid tmin_${EXP}_${DATASET}_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
	
echo 
echo "1.3. Delete files"
rm *_${EXP}_${DATASET}_day_${DT}.nc

elif [ ${DATASET} == 'CRU' ]
then
echo 
echo "2.  ------------------------------- PROCCESSING CRU DATASET -------------------------------"

echo
echo "2.1. Select date"
cdo seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/cld.dat.nc cld_${DATASET}_mon_${DT}.nc
cdo seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/pre.dat.nc pre_${DATASET}_mon_${DT}.nc
cdo seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/tmp.dat.nc tmp_${DATASET}_mon_${DT}.nc
cdo seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/tmx.dat.nc tmx_${DATASET}_mon_${DT}.nc
cdo seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/tmn.dat.nc tmn_${DATASET}_mon_${DT}.nc

echo 
echo "2.2. Convert unit"
cdo divc,30.5 pre_${DATASET}_mon_${DT}.nc pre_${EXP}_${DATASET}_mon_${DT}.nc
cp cld_${DATASET}_mon_${DT}.nc cld_${EXP}_${DATASET}_mon_${DT}.nc
cp tmp_${DATASET}_mon_${DT}.nc tmp_${EXP}_${DATASET}_mon_${DT}.nc
cp tmx_${DATASET}_mon_${DT}.nc tmx_${EXP}_${DATASET}_mon_${DT}.nc
cp tmn_${DATASET}_mon_${DT}.nc tmn_${EXP}_${DATASET}_mon_${DT}.nc

echo 
echo "2.3. Regrid output"
${REGRIG}/./regrid cld_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${REGRIG}/./regrid pre_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${REGRIG}/./regrid tmp_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${REGRIG}/./regrid tmx_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${REGRIG}/./regrid tmn_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo 
echo "2.4. Delete files"
rm *_${DATASET}_mon_${DT}.nc
rm *_${EXP}_${DATASET}_mon_${DT}.nc


elif [ ${DATASET} == 'ERA5' ]
then
echo 
echo "3.  ------------------------------- PROCCESSING ERA5 DATASET -------------------------------"

echo
echo "3.1. Merge dates"
cdo cat ${DIR_IN}/${DATASET}/daily/pr_2018_*_day.nc tp_${DATASET}_day_2018.nc
cdo cat ${DIR_IN}/${DATASET}/daily/pr_2019_*_day.nc tp_${DATASET}_day_2019.nc
cdo cat ${DIR_IN}/${DATASET}/daily/pr_2020_*_day.nc tp_${DATASET}_day_2020.nc
cdo cat ${DIR_IN}/${DATASET}/daily/pr_2021_*_day.nc tp_${DATASET}_day_2021.nc
cdo cat tp_${DATASET}_day_* tp_${DATASET}_day_${DT}.nc

cdo cat ${DIR_IN}/${DATASET}/daily/tas_2018_*_day.nc t2m_${DATASET}_day_2018.nc
cdo cat ${DIR_IN}/${DATASET}/daily/tas_2019_*_day.nc t2m_${DATASET}_day_2019.nc
cdo cat ${DIR_IN}/${DATASET}/daily/tas_2020_*_day.nc t2m_${DATASET}_day_2020.nc
cdo cat ${DIR_IN}/${DATASET}/daily/tas_2021_*_day.nc t2m_${DATASET}_day_2021.nc
cdo cat t2m_${DATASET}_day_* t2m_${DATASET}_day_${DT}.nc

echo 
echo "3.2. Convert unit"
cdo mulc,24000 tp_${DATASET}_day_${DT}.nc tp_${EXP}_${DATASET}_day_${DT}.nc
cdo subc,273.15 t2m_${DATASET}_day_${DT}.nc t2m_${EXP}_${DATASET}_day_${DT}.nc

echo 
echo "3.3. Calculate monthly mean"
cdo monmean tp_${EXP}_${DATASET}_day_${DT}.nc tp_${EXP}_${DATASET}_mon_${DT}.nc
cdo monmean t2m_${EXP}_${DATASET}_day_${DT}.nc t2m_${EXP}_${DATASET}_mon_${DT}.nc

echo 
echo "3.4. Regrid output"
${REGRIG}/./regrid tp_${EXP}_${DATASET}_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${REGRIG}/./regrid tp_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${REGRIG}/./regrid t2m_${EXP}_${DATASET}_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${REGRIG}/./regrid t2m_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo 
echo "3.5. Delete files"
rm tp_${DATASET}_day_*.nc
rm t2m_${DATASET}_day_*.nc
rm *_${DATASET}_day_${DT}.nc
rm *_${EXP}_${DATASET}_day_${DT}.nc
rm *_${EXP}_${DATASET}_mon_${DT}.nc

else
echo 
echo "4. ------------------------------- PROCCESSING GPCP DATASET -------------------------------"

echo
echo "4.1. Select date"
cdo seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/GPCPMON_L3_198301-202209_V3.2.nc4 ${DATASET}_${EXP}_mon_${DT}.nc

echo 
echo "4.2. Select variable"
cdo selvar,sat_gauge_precip ${DATASET}_${EXP}_mon_${DT}.nc sat_gauge_precip_${DATASET}_${EXP}_mon_${DT}.nc

echo 
echo "4.3. Regrid output"
${REGRIG}/./regrid sat_gauge_precip_${DATASET}_${EXP}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo 
echo "4.4. Delete files"
rm *${DATASET}_${EXP}_mon_${DT}.nc

fi
