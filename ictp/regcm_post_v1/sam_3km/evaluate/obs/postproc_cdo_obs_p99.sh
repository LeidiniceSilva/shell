#!/bin/bash

#SBATCH -A ICT23_ESP_1
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

YR="2018-2018"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

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
VAR="precip"
    
echo
echo "Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}.cpc.day.1979-2024.nc ${VAR}_${EXP}_${DATASET}_${YR}.nc

echo
echo "Calculate p99"
CDO timmin ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_min.nc
CDO timmax ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_max.nc
CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_min.nc ${VAR}_${EXP}_${DATASET}_${YR}_max.nc p99_${EXP}_${DATASET}_${YR}.nc
  
echo
echo "Regrid variable"
${BIN}/./regrid p99_${EXP}_${DATASET}_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

elif [ ${DATASET} == 'ERA5' ]
then
VAR="tp"

echo
echo "Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_1hr_2018-2021.nc ${VAR}_${DATASET}_1hr_${YR}.nc

echo
echo "Convert unit"
CDO -b f32 mulc,1000 ${VAR}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc
CDO daysum ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}.nc

echo
echo "Calculate p99"
CDO timmin ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_min.nc
CDO timmax ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_max.nc
CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_min.nc ${VAR}_${EXP}_${DATASET}_${YR}_max.nc p99_${EXP}_${DATASET}_${YR}.nc
  
echo
echo "Regrid variable"
${BIN}/./regrid p99_${EXP}_${DATASET}_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

else
VAR="cmorph"

echo
echo "Select date"
FILE_IN=$( eval ls ${DIR_IN}/${DATASET}/${VAR}_CSAM-3_CMORPH_1hr_{${IYR}..${FYR}}.nc )
FILE_OUT=${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc
[[ ! -f $FILE_OUT ]] && CDO -b f32 mergetime $FILE_IN $FILE_OUT
CDO daysum ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}.nc

echo
echo "Calculate p99"
CDO timmin ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_min.nc
CDO timmax ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_max.nc
CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}_min.nc ${VAR}_${EXP}_${DATASET}_${YR}_max.nc p99_${EXP}_${DATASET}_${YR}.nc
  
echo
echo "Regrid variable"
${BIN}/./regrid p99_${EXP}_${DATASET}_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

fi

echo 
echo "Delete files"
rm *_${YR}.nc
rm ${VAR}_${EXP}_${DATASET}_${YR}_min.nc
rm ${VAR}_${EXP}_${DATASET}_${YR}_max.nc

}
