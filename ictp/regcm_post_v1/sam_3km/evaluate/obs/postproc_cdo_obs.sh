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
EXP="SAM-3km"

YR="2018-2021"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/evaluate/obs"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo 
echo "------------------------------- PROCCESSING ${DATASET} DATASET -------------------------------"

if [ ${DATASET} == 'CPC' ]
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
    echo "Regrid"
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_day_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

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
    echo "Select date"
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cru_ts4.08.1901.2023.${VAR}.dat.nc ${VAR}_${DATASET}_mon_${YR}.nc
    
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
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

    echo
    echo "Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_mon_${YR}_lonlat.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
    done
done

elif [ ${DATASET} == 'ERA5' ]
then
VAR_LIST="tp t2m tcc lcc mcc hcc msnlwrf avg_pevr pev cc ciwc clwc u v q r"

for VAR in ${VAR_LIST[@]}; do

    echo
    echo "Select date"
    if [ ${VAR} == 'tp' ]
    then
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_1hr_2018-2021.nc ${VAR}_${DATASET}_1hr_${YR}.nc
    else
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_2018-2021.nc ${VAR}_${DATASET}_${YR}.nc
    fi

    echo
    echo "convert unit"
    if [ ${VAR} == 'tp' ]
    then
    CDO -b f32 mulc,1000 ${VAR}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc
    CDO daysum ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_day_${YR}.nc
    CDO monmean ${VAR}_${EXP}_${DATASET}_day_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    elif [ ${VAR} == 't2m' ] 
    then
    CDO -b f32 subc,273.15 ${VAR}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    else
    cp ${VAR}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc
    fi 
   
    echo
    echo "Regrid and select subdomain"
    if [ ${VAR} == 'tp' ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil 
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_day_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil 
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil  
    else
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_mon_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    fi  

    echo
    echo "Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
	CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_mon_${YR}_lonlat.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
    done       
done

elif [ ${DATASET} == 'GPCP' ]
then
echo
echo "Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/GPCPMON_L3_198301-202209_V3.2.nc4 ${EXP}_${DATASET}_mon_${YR}.nc

echo 
echo "Select variable"
CDO selvar,sat_gauge_precip ${EXP}_${DATASET}_mon_${YR}.nc sat_gauge_precip_${EXP}_${DATASET}_mon_${YR}.nc

echo 
echo "Regrid output"
${BIN}/./regrid sat_gauge_precip_${EXP}_${DATASET}_mon_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo
echo "Seasonal avg"
for SEASON in ${SEASON_LIST[@]}; do
    CDO -timmean -selseas,${SEASON} sat_gauge_precip_${EXP}_${DATASET}_mon_${YR}_lonlat.nc sat_gauge_precip_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
done

else
echo
echo "Select date"
FILE_IN=$( eval ls ${DIR_IN}/${DATASET}/cmorph_CSAM-3_CMORPH_1hr_{${IYR}..${FYR}}.nc )
FILE_OUT=cmorph_${EXP}_${DATASET}_1hr_${YR}.nc
[[ ! -f $FILE_OUT ]] && CDO -b f32 mergetime $FILE_IN $FILE_OUT
CDO daysum cmorph_${EXP}_${DATASET}_1hr_${YR}.nc cmorph_${EXP}_${DATASET}_day_${YR}.nc
CDO monmean cmorph_${EXP}_${DATASET}_day_${YR}.nc cmorph_${EXP}_${DATASET}_mon_${YR}.nc

echo 
echo "Regrid output"
${BIN}/./regrid cmorph_${EXP}_${DATASET}_1hr_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid cmorph_${EXP}_${DATASET}_day_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid cmorph_${EXP}_${DATASET}_mon_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo
echo "Seasonal avg"
for SEASON in ${SEASON_LIST[@]}; do
    CDO -timmean -selseas,${SEASON} cmorph_${EXP}_${DATASET}_mon_${YR}_lonlat.nc cmorph_${EXP}_${DATASET}_${SEASON}_${YR}_lonlat.nc
done
fi

echo 
echo "Delete files"
rm *_${YR}.nc

}
