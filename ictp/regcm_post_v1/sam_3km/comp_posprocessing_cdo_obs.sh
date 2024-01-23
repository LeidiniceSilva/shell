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

DATASET="CPC"

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

VAR_LIST="precip tmax tmin"

for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "1.1. Select date"
    if [ ${VAR} == 'precip' ]
    then
    CDO seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/cpc.day.1979-2021.nc ${VAR}_${EXP}_${DATASET}_day_${DT}.nc
    else
    CDO seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/${VAR}.1979-2021.nc ${VAR}_${EXP}_${DATASET}_day_${DT}.nc
    
    echo
    echo "1.2. Monthly avg"
    CDO monmean ${VAR}_${EXP}_${DATASET}_day_${DT}.nc ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc

    echo
    echo "1.3. Regrid output"
    if [ ${VAR} == 'precip' ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    else
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

    echo
    echo "1.4. Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_mon_${DT}_lonlat.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
    done
done

echo
echo "1.5. Select subdomain"
CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_${DATASET}_day_${DT}_lonlat.nc ${VAR}_SESA-3km_${DATASET}_day_${DT}_lonlat.nc

echo 
echo "1.6. Delete files"
rm *_${EXP}_${DATASET}_*_${DT}.nc

elif [ ${DATASET} == 'CRU' ]
then
echo 
echo "2.  ------------------------------- PROCCESSING CRU DATASET -------------------------------"

VAR_LIST="pre tmp tmx tmn cld"

for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "2.1. Select date"
    CDO seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/${VAR}.dat.nc ${VAR}_${DATASET}_mon_${DT}.nc
    
    echo
    echo "2.2. Convert unit"
    if [ ${VAR} == 'tp' ]
    then
    CDO -b f32 divc,30.5 ${VAR}_${DATASET}_mon_${DT}.nc ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc
    else
    cp ${VAR}_${DATASET}_mon_${DT}.nc ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc
    
    echo
    echo "2.3. Regrid output"
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    
    echo
    echo "2.4. Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_mon_${DT}_lonlat.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
    done
done

echo
echo "2.5. Select subdomain"
CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_${DATASET}_mon_${DT}_lonlat.nc ${VAR}_SESA-3km_${DATASET}_mon_${DT}_lonlat.nc

echo 
echo "2.6. Delete files"
rm *_${DATASET}_mon_${DT}.nc

elif [ ${DATASET} == 'ERA5' ]
then
echo 
echo "3.  ------------------------------- PROCCESSING ERA5 DATASET -------------------------------"

VAR_LIST="tp t2m mx2t mn2t tcc mslhf msshf msnlwrf msnswrf cc clwc ciwc q u v"

for VAR in ${VAR_LIST[@]}; do

    echo
    echo "3.1. Convert unit"
    if [ ${VAR} == 'tp' ]
    then
    CDO -b f32 mulc,1000 ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_day_${DT}.nc
    CDO monmean ${VAR}_${DATASET}_day_${DT}.nc ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc
    elif [ ${VAR} == 't2m' ]
    then
    CDO -b f32 subc,273.15 ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc
    elif [ ${VAR} == 'mx2t' ]
    then
    CDO -b f32 subc,273.15 ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc
    elif [ ${VAR} == 'mn2t' ]
    then
    CDO -b f32 subc,273.15 ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc
    elif [ ${VAR} == 'tcc' ]
    then
    CDO -b f32 mulc,100 ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc
    elif [ ${VAR} == 'mslhf' ]
    then
    CDO -b f32 mulc,-1 ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc
    elif [ ${VAR} == 'msshf' ]
    then
    CDO -b f32 mulc,-1 ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc
    elif [ ${VAR} == 'msnlwrf' ]
    then
    CDO -b f32 mulc,-1 ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc
    elif [ ${VAR} == 'msnswrf' ]
    then
    CDO -b f32 mulc,-1 ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc
    else
    cp ${VAR}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc
    fi
    
    echo
    echo "3.2. Regrid and select subdomain"
    if [ ${VAR} == 'tp' ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_${DATASET}_day_${DT}_lonlat.nc ${VAR}_SESA-3km_${DATASET}_day_${DT}_lonlat.nc
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_${DATASET}_mon_${DT}_lonlat.nc ${VAR}_SESA-3km_${DATASET}_mon_${DT}_lonlat.nc
    elif [ ${VAR} == 't2m' ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_${DATASET}_mon_${DT}_lonlat.nc ${VAR}_SESA-3km_${DATASET}_mon_${DT}_lonlat.nc
    elif [ ${VAR} == 'cc' ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_${DATASET}_mon_${DT}_lonlat.nc ${VAR}_SESA-3km_${DATASET}_mon_${DT}_lonlat.nc
    elif [ ${VAR} == 'ciwc' ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_${DATASET}_mon_${DT}_lonlat.nc ${VAR}_SESA-3km_${DATASET}_mon_${DT}_lonlat.nc
    elif [ ${VAR} == 'clwc' ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_${DATASET}_mon_${DT}_lonlat.nc ${VAR}_SESA-3km_${DATASET}_mon_${DT}_lonlat.nc
    else
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    fi
    
    echo
    echo "3.3. Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        if [ ${VAR} == 'cc' ]
	then
	CDO -timmean -selseas,${SEASON} ${VAR}_SESA-3km_${DATASET}_mon_${DT}_lonlat.nc ${VAR}_SESA-3km_${DATASET}_${SEASON}_${DT}_lonlat.nc
	elif [ ${VAR} == 'ciwc' ]
	then
	CDO -timmean -selseas,${SEASON} ${VAR}_SESA-3km_${DATASET}_mon_${DT}_lonlat.nc ${VAR}_SESA-3km_${DATASET}_${SEASON}_${DT}_lonlat.nc
	elif [ ${VAR} == 'clwc' ]
	then
	CDO -timmean -selseas,${SEASON} ${VAR}_SESA-3km_${DATASET}_mon_${DT}_lonlat.nc ${VAR}_SESA-3km_${DATASET}_${SEASON}_${DT}_lonlat.nc
	elif [ ${VAR} == 'q' ]
	then
	CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_mon_${DT}_lonlat.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
	CDO sellevel,200 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_200hPa_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
	CDO sellevel,500 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_500hPa_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
	CDO sellevel,850 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_850hPa_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
	elif [ ${VAR} == 'u' ]
	then
	CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_mon_${DT}_lonlat.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
	CDO sellevel,200 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_200hPa_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
	CDO sellevel,500 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_500hPa_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
	CDO sellevel,850 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_850hPa_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
	elif [ ${VAR} == 'v' ]
	then
	CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_mon_${DT}_lonlat.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
	CDO sellevel,200 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_200hPa_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
	CDO sellevel,500 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_500hPa_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
	CDO sellevel,850 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ${VAR}_850hPa_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
	else
	CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_mon_${DT}_lonlat.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
	fi
    done       
done

echo 
echo "3.5. Delete files"
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
echo "4.4. Select subdomain"
CDO sellonlatbox,-65,-52,-35,-24 sat_gauge_precip_${EXP}_${DATASET}_mon_${DT}_lonlat.nc sat_gauge_precip_SESA-3km_${DATASET}_mon_${DT}_lonlat.nc

echo
echo "4.5. Seasonal avg"
for SEASON in ${SEASON_LIST[@]}; do
    CDO -timmean -selseas,${SEASON} sat_gauge_precip_${EXP}_${DATASET}_mon_${DT}_lonlat.nc sat_gauge_precip_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc
done
 
echo 
echo "4.6. Delete files"
rm *${DATASET}_mon_${DT}.nc

fi

}
