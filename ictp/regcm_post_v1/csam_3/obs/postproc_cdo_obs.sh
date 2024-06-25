#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the OBS datasets with CDO'

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="2000-2000"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

EXP="CSAM-3"
DATASET="ERA5"

DIR_IN="/marconi/home/userexternal/mdasilva/OBS"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/CORDEX/post_evaluate/obs"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

if [ ${DATASET} == 'CPC' ]
then
echo 
echo "1. ------------------------------- PROCCESSING ${DATASET} DATASET -------------------------------"

VAR_LIST="precip tmax tmin"
for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "1.1. Select date"
    if [ ${VAR} == 'precip' ]
    then
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cpc.day.1979-2021.nc ${VAR}_${EXP}_${DATASET}_day_${YR}.nc
    else
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}.1979-2021.nc ${VAR}_${EXP}_${DATASET}_day_${YR}.nc
    fi
    
    echo
    echo "1.2. Monthly avg"
    CDO monmean ${VAR}_${EXP}_${DATASET}_day_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc

    echo
    echo "1.3. Regrid output"
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_day_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

    echo
    echo "1.4. Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_mon_${YR}_lonlat.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
    done
done

echo 
echo "1.5. Delete files"
rm *_${EXP}_${DATASET}_*_${YR}.nc

elif [ ${DATASET} == 'CRU' ]
then
echo 
echo "2.  ------------------------------- PROCCESSING ${DATASET} DATASET -------------------------------"

VAR_LIST="pre tmp tmx tmn cld"
for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "2.1. Select date"
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}.dat.nc ${VAR}_${DATASET}_mon_${YR}.nc
    
    echo
    echo "2.2. Convert unit"
    if [ ${VAR} == 'pre' ]
    then
    CDO -b f32 divc,30.5 ${VAR}_${DATASET}_mon_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    else
    cp ${VAR}_${DATASET}_mon_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    fi
    
    echo
    echo "2.3. Regrid"
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

    echo
    echo "2.4. Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_mon_${YR}_lonlat.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
    done
done

echo 
echo "2.5. Delete files"
rm *_${DATASET}_mon_${YR}.nc

elif [ ${DATASET} == 'ERA5' ]
then
echo 
echo "3.  ------------------------------- PROCCESSING ${DATASET} DATASET -------------------------------"

VAR_LIST="pr tas"
for VAR in ${VAR_LIST[@]}; do

    echo
    echo "3.1. Select date"
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_2000-2009.nc ${VAR}_${DATASET}_${YR}.nc
    
    echo
    echo "3.2. Convert unit"
    if [ ${VAR} == 'pr' ]
    then
    CDO -b f32 mulc,1000 ${VAR}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    elif [ ${VAR} == 'tas' ]
    then
    CDO -b f32 subc,273.15 ${VAR}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    elif [ ${VAR} == 'tcc' ]
    then
    CDO -b f32 mulc,100 ${VAR}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    else
    cp ${VAR}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    fi
    
    echo
    echo "3.3. Regrid and select subdomain"
    if [ ${VAR} == 'pr' ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    elif [ ${VAR} == 'tas' ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    elif [ ${VAR} == 'cc' ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_${DATASET}_mon_${YR}_lonlat.nc ${VAR}_SESA-3km_${DATASET}_mon_${YR}_lonlat.nc
    elif [ ${VAR} == 'ciwc' ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_${DATASET}_mon_${YR}_lonlat.nc ${VAR}_SESA-3km_${DATASET}_mon_${YR}_lonlat.nc
    elif [ ${VAR} == 'clwc' ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_${DATASET}_mon_${YR}_lonlat.nc ${VAR}_SESA-3km_${DATASET}_mon_${YR}_lonlat.nc
    else
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    fi
    
    echo
    echo "3.4. Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        if [ ${VAR} == 'cc' ]
	then
	CDO -timmean -selseas,${SEASON} ${VAR}_SESA-3km_${DATASET}_mon_${YR}_lonlat.nc ${VAR}_SESA-3km_${DATASET}_${SEASON}_${YR}_lonlat.nc
	elif [ ${VAR} == 'ciwc' ]
	then
	CDO -timmean -selseas,${SEASON} ${VAR}_SESA-3km_${DATASET}_mon_${YR}_lonlat.nc ${VAR}_SESA-3km_${DATASET}_${SEASON}_${YR}_lonlat.nc
	elif [ ${VAR} == 'clwc' ]
	then
	CDO -timmean -selseas,${SEASON} ${VAR}_SESA-3km_${DATASET}_mon_${YR}_lonlat.nc ${VAR}_SESA-3km_${DATASET}_${SEASON}_${YR}_lonlat.nc
	elif [ ${VAR} == 'q' ]
	then
	CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_mon_${YR}_lonlat.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
	CDO sellevel,200 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc ${VAR}_200hPa_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
	CDO sellevel,500 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc ${VAR}_500hPa_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
	CDO sellevel,850 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc ${VAR}_850hPa_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
	elif [ ${VAR} == 'u' ]
	then
	CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_mon_${YR}_lonlat.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
	CDO sellevel,200 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc ${VAR}_200hPa_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
	CDO sellevel,500 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc ${VAR}_500hPa_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
	CDO sellevel,850 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc ${VAR}_850hPa_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
	elif [ ${VAR} == 'v' ]
	then
	CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_mon_${YR}_lonlat.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
	CDO sellevel,200 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc ${VAR}_200hPa_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
	CDO sellevel,500 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc ${VAR}_500hPa_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
	CDO sellevel,850 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc ${VAR}_850hPa_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
	else
	CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_mon_${YR}_lonlat.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
	fi
    done       
done

echo 
echo "3.5. Delete files"
rm *_${DATASET}_${YR}.nc
rm *_${DATASET}_day_${YR}.nc
rm *_${DATASET}_mon_${YR}.nc

elif [ ${DATASET} == 'GPCP' ]
then
echo 
echo "4. ------------------------------- PROCCESSING ${DATASET} DATASET -------------------------------"

echo
echo "4.1. Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/GPCPMON_L3_198301-202209_V3.2.nc4 ${EXP}_${DATASET}_mon_${YR}.nc

echo 
echo "4.2. Select variable"
CDO selvar,sat_gauge_precip ${EXP}_${DATASET}_mon_${YR}.nc sat_gauge_precip_${EXP}_${DATASET}_mon_${YR}.nc

echo 
echo "4.3. Regrid output"
${BIN}/./regrid sat_gauge_precip_${EXP}_${DATASET}_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

echo
echo "4.4. Seasonal avg"
for SEASON in ${SEASON_LIST[@]}; do
    CDO -timmean -selseas,${SEASON} sat_gauge_precip_${EXP}_${DATASET}_mon_${YR}_lonlat.nc sat_gauge_precip_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
done

echo 
echo "4.5. Delete files"
rm *${DATASET}_mon_${YR}.nc

else
echo 
echo "5. ------------------------------- PROCCESSING ${DATASET} DATASET -------------------------------"

echo
echo "5.1. Average"
CDO daysum ${DIR_IN}/${DATASET}/precipitation_SAM-10km_${DATASET}_3B-V0A7_1hr_2018-2021.nc precipitation_${EXP}_${DATASET}_3B-V0A7_day_${YR}.nc
CDO monmean precipitation_${EXP}_${DATASET}_3B-V0A7_day_${YR}.nc precipitation_${EXP}_${DATASET}_3B-V0A7_mon_${YR}.nc

echo 
echo "5.2. Regrid output"
${BIN}/./regrid precipitation_${EXP}_${DATASET}_3B-V0A7_day_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid precipitation_${EXP}_${DATASET}_3B-V0A7_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

echo
echo "5.3. Seasonal avg"
for SEASON in ${SEASON_LIST[@]}; do
    CDO -timmean -selseas,${SEASON} precipitation_${EXP}_${DATASET}_3B-V0A7_mon_${YR}_lonlat.nc precipitation_${EXP}_${DATASET}_3B-V0A7_${SEASON}_${YR}_lonlat.nc
done

echo 
echo "5.4. Delete files"
rm precipitation_${EXP}_${DATASET}_3B-V0A7_*_${YR}.nc

fi

}
