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
#__date__        = 'Mar 15, 2024'
#__description__ = 'Postprocessing the dataset with CDO'
 
{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="SAM-3km"
DATASET="ERA5"
YR="2018-2021"
VAR_LIST="cape cin tp msl u10 v10"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS/ERA5"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/cyclone/era5"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING DATASET ----------------"

for VAR in ${VAR_LIST[@]}; do

    echo
    echo "Merge files"
    FILE_IN=$( eval ls ${VAR}_${DATASET}_1hr_{2018..2021}.nc )
    FILE_OUT=${VAR}_${DATASET}_1hr_${YR}.nc
    [[ ! -f $FILE_OUT ]] && CDO -b f32 mergetime $FILE_IN $FILE_OUT

    echo
    echo "Regrid files"
    if [ ${VAR} == "tp" ]
    then
    CDO -b f32 mulc,1000 ${DIR_IN}/${VAR}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc
    CDO daysum ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_day_${YR}.nc
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_1hr_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil	
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_day_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil	
    else
    CDO selhour,00,06,12,18 ${DIR_IN}/${VAR}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_6hr_${YR}.nc
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_6hr_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil	
    fi
   
done
    
echo
echo "--------------- THE END POSPROCESSING DATASET ----------------"

}
