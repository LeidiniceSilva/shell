#!/bin/bash

#SBATCH -A CMPNS_ictpclim
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
YR="2000-2009"
VAR_LIST="msl u10 v10"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/TRACK-CYCLONE/Test-Mi/ERA5"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/TRACK-CYCLONE/Test-Mi/postproc"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING DATASET ----------------"

for VAR in ${VAR_LIST[@]}; do

    echo
    echo "1. Regrid and smooth"
    ${BIN}/./regrid ${DIR_IN}/${VAR}_${DATASET}_${YR}.nc -55,-20,1.5 -88,-30,1.5 bil
    CDO smooth ${VAR}_${DATASET}_${YR}_lonlat.nc ${VAR}_${DATASET}_${YR}_smooth.nc
    CDO smooth ${VAR}_${DATASET}_${YR}_smooth.nc ${VAR}_${EXP}_${DATASET}_${YR}_smooth2.nc

done
    
echo
echo "--------------- THE END POSPROCESSING DATASET ----------------"

}
