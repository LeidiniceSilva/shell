#!/bin/bash

#SBATCH -A ICT25_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the OBS datasets with CDO'

{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DATASET=$1
EXP="CSAM-3"

YR="2000-2009"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/evaluate/obs"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo 
echo "------------------------------- INIT POSTPROCESSING ${DATASET} -------------------------------"

if [ ${DATASET} == 'CMORPH' ]
then

echo
echo "Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cmorph_CSAM-3_CMORPH_1hr_2000-2009.nc cmorph_${EXP}_${DATASET}_1hr_${YR}.nc

echo
echo "Monthly avg"
CDO daysum cmorph_${EXP}_${DATASET}_1hr_${YR}.nc cmorph_${EXP}_${DATASET}_day_${YR}.nc
CDO monmean cmorph_${EXP}_${DATASET}_day_${YR}.nc cmorph_${EXP}_${DATASET}_mon_${YR}.nc

echo 
echo "Regrid output"
${BIN}/./regrid cmorph_${EXP}_${DATASET}_1hr_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid cmorph_${EXP}_${DATASET}_day_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
${BIN}/./regrid cmorph_${EXP}_${DATASET}_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

echo
echo "Seasonal avg"
for SEASON in ${SEASON_LIST[@]}; do
    CDO -timmean -selseas,${SEASON} cmorph_${EXP}_${DATASET}_mon_${YR}_lonlat.nc cmorph_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
done

elif [ ${DATASET} == 'CPC' ]
then

VAR_LIST="precip tmax tmin"
for VAR in ${VAR_LIST[@]}; do
    echo
    echo "Select date"
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}.cpc.day.1979-2024.nc ${VAR}_${EXP}_${DATASET}_day_${YR}.nc   

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

VAR_LIST="pre tmp tmx tmn cld"
for VAR in ${VAR_LIST[@]}; do
    echo
    echo "Convert unit"
    if [ ${VAR} == 'pre' ]
    then
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cru_ts4.08.1901.2023.${VAR}.dat.nc ${VAR}_${DATASET}_mon_${YR}.nc
    CDO -b f32 divc,30.5 ${VAR}_${DATASET}_mon_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    elif [ ${VAR} == 'cld' ]
    then
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cru_ts4.08.1901.2023.${VAR}.dat.nc ${VAR}_${DATASET}_mon_${YR}.nc
    CDO -b f32 divc,100 ${VAR}_${DATASET}_mon_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    else
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cru_ts4.08.1901.2023.${VAR}.dat.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
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

VAR_LIST="tp t2m tasmax tasmin cc tcc lcc mcc hcc msdwlwrf pev u v q r cape cin"
for VAR in ${VAR_LIST[@]}; do
    echo
    echo "Select date"
    if [ ${VAR} == 'tp' ]
    then
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}_ERA5_1hr_2000-2009.nc ${VAR}_${DATASET}_1hr_${YR}.nc
    else
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}_ERA5_2000-2009.nc ${VAR}_${DATASET}_${YR}.nc
    fi

    echo
    echo "convert unit"
    if [ ${VAR} == 'tp' ]
    then
    CDO -b f32 mulc,1000 ${VAR}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc
    CDO daysum ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_day_${YR}.nc
    CDO monmean ${VAR}_${EXP}_${DATASET}_day_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    elif [ ${VAR} == 't2m' ] || [ ${VAR} == 'tasmax' ] || [ ${VAR} == 'tasmin' ]
    then
    CDO -b f32 subc,273.15 ${VAR}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    elif [ ${VAR} == 'pev' ]
    then
    CDO -b f32 mulc,1000 ${VAR}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    else
    cp ${VAR}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    fi    

    echo
    echo "Regrid and select subdomain"
    if [ ${VAR} == 'tp' ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil  
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_day_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil  
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil 
    else
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil 
    fi
 
    echo
    echo "Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
	CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_mon_${YR}_lonlat.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
    done       
done

else
echo
echo "Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/mswep.day.1979-2020.nc precipitation_${EXP}_${DATASET}_day_${YR}.nc

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
fi

echo 
echo "Delete files"
rm *_${YR}.nc

echo 
echo "------------------------------- THE END POSTPROCESSING ${DATASET} -------------------------------"

}
