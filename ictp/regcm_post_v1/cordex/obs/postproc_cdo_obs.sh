#!/bin/bash

#SBATCH -N 1 
#SBATCH -t 24:00:00
#SBATCH -A ICT23_ESP
#SBATCH --qos=qos_prio
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p skl_usr_prod

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

YR="2000-2009"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

DATASET=$1
EXP="CSAM-3"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/OBS"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/CORDEX/post_evaluate/obs"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

if [ ${DATASET} == 'CMORPH' ]
then
echo 
echo "------------------------------- PROCCESSING ${DATASET} DATASET -------------------------------"

echo
echo "Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cmorph_CSAM-3_CMORPH_1hr_2000-2009.nc cmorph_${EXP}_${DATASET}_1hr_${YR}.nc

echo
echo "Monthly avg"
CDO daysum cmorph_${EXP}_${DATASET}_1hr_${YR}.nc cmorph_${EXP}_${DATASET}_day_${YR}.nc
CDO monmean cmorph_${EXP}_${DATASET}_day_${YR}.nc cmorph_${EXP}_${DATASET}_mon_${YR}.nc

echo 
echo "Regrid output"
${BIN}/./regrid cmorph_${EXP}_${DATASET}_day_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid cmorph_${EXP}_${DATASET}_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

echo
echo "Seasonal avg"
for SEASON in ${SEASON_LIST[@]}; do
    CDO -timmean -selseas,${SEASON} cmorph_${EXP}_${DATASET}_mon_${YR}_lonlat.nc cmorph_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
done

elif [ ${DATASET} == 'CPC' ]
then
echo 
echo "------------------------------- PROCCESSING ${DATASET} DATASET -------------------------------"

VAR_LIST="precip tmax tmin"
for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "Select date"
    if [ ${VAR} == 'precip' ]
    then
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cpc.day.1979-2021.nc ${VAR}_${EXP}_${DATASET}_day_${YR}.nc
    else
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}.1979-2021.nc ${VAR}_${EXP}_${DATASET}_day_${YR}.nc
    fi
    
    echo
    echo "Monthly avg"
    CDO monmean ${VAR}_${EXP}_${DATASET}_day_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc

    echo
    echo "Regrid output"
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_day_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

    echo
    echo "Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_mon_${YR}_lonlat.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
    done
done

elif [ ${DATASET} == 'CRU' ]
then
echo 
echo "------------------------------- PROCCESSING ${DATASET} DATASET -------------------------------"

VAR_LIST="pre tmp tmx tmn cld"
for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "Select date"
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}.dat.nc ${VAR}_${DATASET}_mon_${YR}.nc
    
    echo
    echo "Convert unit"
    if [ ${VAR} == 'pre' ]
    then
    CDO -b f32 divc,30.5 ${VAR}_${DATASET}_mon_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    else
    cp ${VAR}_${DATASET}_mon_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    fi
    
    echo
    echo "Regrid"
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

    echo
    echo "Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_mon_${YR}_lonlat.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
    done
done

elif [ ${DATASET} == 'ERA5' ]
then
echo 
echo "------------------------------- PROCCESSING ${DATASET} DATASET -------------------------------"

VAR_LIST="lcc mcc hcc tcc tp t2m mx2t mn2t msnlwrf msnswrf msdwlwrf msdwswrf q u v evpot cape cin"

for VAR in ${VAR_LIST[@]}; do

    echo
    echo "Select date and convert unit"
    if [ ${VAR} == 'tp' ]
    then
    CDO -b f32 mulc,1000 ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_1hr_${YR}.nc ${VAR}_${DATASET}_1hr_${YR}.nc
    CDO daysum ${VAR}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_day_${YR}.nc
    CDO monmean ${VAR}_${EXP}_${DATASET}_day_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    elif [ ${VAR} == 't2m' ] || [ ${VAR} == 'mx2t' ] || [ ${VAR} == 'mn2t' ]
    then
    CDO -b f32 subc,273.15 ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    elif [ ${VAR} == 'evpot' ]
    then
    CDO -b f32 mulc,-1000 ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    elif [ ${VAR} == 'msnlwrf' ]
    then
    CDO -b f32 mulc,-1 ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    else
    cp ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    fi
    
    echo
    echo "Regrid and select subdomain"
    if [ ${VAR} == 'tp' ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_day_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    else
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    fi
   
    echo
    echo "Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
	if [ ${VAR} == 'q' ] || [ ${VAR} == 'u' ] || [ ${VAR} == 'v' ]
	then
	CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_mon_${YR}_lonlat.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
	CDO sellevel,200 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc ${VAR}_200hPa_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
	CDO sellevel,850 ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc ${VAR}_850hPa_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
	else
	CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_mon_${YR}_lonlat.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
	fi
    done       
done

elif [ ${DATASET} == 'GPCP' ]
then
echo 
echo "------------------------------- PROCCESSING ${DATASET} DATASET -------------------------------"

echo
echo "Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/GPCPMON_L3_198301-202209_V3.2.nc4 ${EXP}_${DATASET}_mon_${YR}.nc

echo 
echo "Select variable"
CDO selvar,sat_gauge_precip ${EXP}_${DATASET}_mon_${YR}.nc sat_gauge_precip_${EXP}_${DATASET}_mon_${YR}.nc

echo 
echo "Regrid output"
${BIN}/./regrid sat_gauge_precip_${EXP}_${DATASET}_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

echo
echo "Seasonal avg"
for SEASON in ${SEASON_LIST[@]}; do
    CDO -timmean -selseas,${SEASON} sat_gauge_precip_${EXP}_${DATASET}_mon_${YR}_lonlat.nc sat_gauge_precip_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
done

elif [ ${DATASET} == 'MSWEP' ]
then
echo 
echo "------------------------------- PROCCESSING ${DATASET} DATASET -------------------------------"

echo
echo "Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/precipitation_MSWEP_1979-2020.nc precipitation_${EXP}_${DATASET}_day_${YR}.nc

echo
echo "Monthly avg"
CDO monmean precipitation_${EXP}_${DATASET}_day_${YR}.nc precipitation_${EXP}_${DATASET}_mon_${YR}.nc

echo 
echo "Regrid output"
${BIN}/./regrid precipitation_${EXP}_${DATASET}_day_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid precipitation_${EXP}_${DATASET}_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

echo
echo "Seasonal avg"
for SEASON in ${SEASON_LIST[@]}; do
    CDO -timmean -selseas,${SEASON} precipitation_${EXP}_${DATASET}_mon_${YR}_lonlat.nc precipitation_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
done

else
echo 
echo "------------------------------- PROCCESSING ${DATASET} DATASET -------------------------------"

echo
echo "Select date"
FILE=$( eval ls ${DIR_IN}/${DATASET}/TRMM.day.mean.????.nc )
CDO mergetime ${FILE} hrf_${EXP}_${DATASET}_day_${YR}.nc

echo
echo "Monthly avg"
CDO monmean hrf_${EXP}_${DATASET}_day_${YR}.nc hrf_${EXP}_${DATASET}_mon_${YR}.nc

echo 
echo "Regrid output"
${BIN}/./regrid hrf_${EXP}_${DATASET}_day_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid hrf_${EXP}_${DATASET}_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

echo
echo "Seasonal avg"
for SEASON in ${SEASON_LIST[@]}; do
    CDO -timmean -selseas,${SEASON} hrf_${EXP}_${DATASET}_mon_${YR}_lonlat.nc hrf_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
done

fi

echo 
echo "Delete files"
rm *_${YR}.nc

}
