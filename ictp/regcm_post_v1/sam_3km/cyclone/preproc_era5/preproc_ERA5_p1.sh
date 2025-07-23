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

EXP="SAM-25km"
DATASET="ERA5"
YR="2018-2021"
VAR_LIST="msl u10 v10"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS/ERA5"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/cyclone/ERA5"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"
MASK="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v1/sam_3km/cyclone/mask"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING DATASET ----------------"

for VAR in ${VAR_LIST[@]}; do

    echo
    echo "1. Merge files"
    FILE_IN=$( eval ls ${DIR_IN}/${VAR}_${DATASET}_1hr_{2018..2021}.nc )
    FILE_OUT=${VAR}_${DATASET}_1hr_${YR}.nc
    [[ ! -f $FILE_OUT ]] && CDO -b f32 mergetime $FILE_IN $FILE_OUT

    echo
    echo "2. Regrid and smooth"
    #${BIN}/./regrid ${VAR}_${DATASET}_1hr_${YR}.nc -34.5,-15,1.5 -76,-38.5,1.5 bil
    CDO remapbil,${MASK}/gridded.txt ${DIR_IN}/${VAR}_${DATASET}_1hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}_lonlat.nc
    CDO smooth ${VAR}_${EXP}_${DATASET}_1hr_${YR}_lonlat.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}_smooth.nc
    CDO smooth ${VAR}_${EXP}_${DATASET}_1hr_${YR}_smooth.nc ${VAR}_${EXP}_${DATASET}_1hr_${YR}_smooth2.nc

done
    
echo
echo "--------------- THE END POSPROCESSING DATASET ----------------"

}
