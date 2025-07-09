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

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/cyclone/ERA5"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

EXP="SAM-25km"
DATASET="ERA5"
VAR_LIST="msl u10 v10"

ANO_I=2018
ANO_F=2021 

for VAR in ${VAR_LIST[@]}; do
    
    for YR in $(seq $ANO_I $ANO_F); do
        CDO selyear,$YR ${VAR}_${EXP}_${DATASET}_1hr_2018-2021_smooth2.nc ${VAR}_${EXP}_${DATASET}_${YR}.nc
   	
	for HR in 00 06 12 18; do
            CDO selhour,$HR ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}.${YR}.${HR}.nc
	                
	done
    done
done

}


