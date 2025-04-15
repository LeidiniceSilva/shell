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

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS/${DATASET}"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/obs"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo 
echo "------------------------------- INIT POSTPROCESSING ${DATASET} -------------------------------"

VAR_LIST="tp"
for VAR in ${VAR_LIST[@]}; do

    CDO selmon,1 -selyear,2000 ${DIR_IN}/${VAR}_ERA5_1hr_2000-2009.nc ${VAR}_${DATASET}_1hr_200001.nc
    CDO -b f32 mulc,1000 ${VAR}_${DATASET}_1hr_200001.nc ${VAR}_${EXP}_${DATASET}_1hr_200001.nc
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_1hr_200001.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil 
    
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
