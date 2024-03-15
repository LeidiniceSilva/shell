#!/bin/bash

#SBATCH -J preproctrack
#SBATCH -t 24:00:00
#SBATCH -A ICT23_ESP
#SBATCH --qos=qos_prio
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p skl_usr_prod
#SBATCH -N 1 --ntasks-per-node=20

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 15, 2024'
#__description__ = 'Posprocessing the dataset with CDO'
 
{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="SAM-25km"
DATASET="ERA5"
VAR_LIST="msl u v"

DIR_IN="/marconi_work/ICT23_ESP/mdasilva/SAM-3km/post_cyclone/obs/era5"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"
    
echo
cd ${DIR_IN}
echo ${DIR_IN}

echo
echo "--------------- INIT POSPROCESSING DATASET ----------------"

for VAR in ${VAR_LIST[@]}; do
   
    echo
    echo "1. Regrid"
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_1hr_2018010100-2021123100.nc -35,-15,0.15 -76,-38,0.15 bil
    
    echo
    echo "2. Smooth"
    CDO smooth ${VAR}_${EXP}_${DATASET}_1hr_2018010100-2021123100_lonlat.nc ${VAR}_${EXP}_${DATASET}_1hr_2018010100-2021123100_smooth.nc
    CDO smooth ${VAR}_${EXP}_${DATASET}_1hr_2018010100-2021123100_smooth.nc ${VAR}_${EXP}_${DATASET}_1hr_20180101-20211231.nc
	    	    
    echo
    echo "2. Delete files"
    rm ${VAR}_${EXP}_${DATASET}_1hr_2018010100-2021123100_lonlat.nc
    rm ${VAR}_${EXP}_${DATASET}_1hr_2018010100-2021123100_smooth.nc

done
    
echo
echo "--------------- THE END POSPROCESSING DATASET ----------------"

}
