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

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/evaluate/obs"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo "------------------------------- PROCCESSING ${DATASET} DATASET -------------------------------"

if [ ${DATASET} == 'CMORPH' ]
then
VAR="cmorph"

echo
echo "Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cmorph_CSAM-3_CMORPH_1hr_2000-2009.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc

echo
echo "Calculate p99"
CDO timmin ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}_min.nc
CDO timmax ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}_max.nc
CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}_min.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}_max.nc p99_${EXP}_${DATASET}_1hr_${YR}.nc

echo
echo "Regrid variable"
${BIN}/./regrid p99_${EXP}_${DATASET}_1hr_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil 

else
VAR="tp"

echo
echo "Select date"
CDO -b f32 mulc,1000 ${DIR_IN}/${DATASET}/tp_ERA5_1hr_2000-2009.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc

echo
echo "3. Calculate p99"
CDO timmin ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}_min.nc
CDO timmax ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}_max.nc
CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}_min.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}_max.nc p99_${EXP}_${DATASET}_1hr_${YR}.nc

echo
echo "Regrid variable"
${BIN}/./regrid p99_${EXP}_${DATASET}_1hr_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
fi

echo 
echo "Delete files"
rm ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc
rm ${VAR}_${EXP}_${DATASET}_1hr_${YR}_min.nc
rm ${VAR}_${EXP}_${DATASET}_1hr_${YR}_max.nc
rm p99_${EXP}_${DATASET}_1hr_${YR}.nc

echo 
echo "------------------------------- THE END POSTPROCESSING ${DATASET} -------------------------------"

}
