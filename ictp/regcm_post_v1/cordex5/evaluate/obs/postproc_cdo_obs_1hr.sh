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
EXP="CSAM-3"

YR="2000-2000"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/obs"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo 
echo "------------------------------- INIT POSTPROCESSING ${DATASET} -------------------------------"

if [ ${DATASET} == 'CMORPH' ]
then
VAR="cmorph"
echo
echo "Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cmorph_CSAM-3_CMORPH_1hr_2000-2009.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc
echo
echo "Regrid variable"
${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil 

else
VAR="pr"
echo
echo "Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/pr_ERA5_1hr_2000-2009.nc ${VAR}_${DATASET}_1hr_${YR}.nc
CDO -b f32 mulc,1000 ${VAR}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc
echo
echo "Regrid variable"
${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
fi

echo 
echo "Delete files"
rm *_${YR}.nc

echo 
echo "------------------------------- THE END POSTPROCESSING ${DATASET} -------------------------------"

}
