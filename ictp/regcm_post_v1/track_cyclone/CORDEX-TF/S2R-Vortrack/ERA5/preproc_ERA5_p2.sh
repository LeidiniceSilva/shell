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

DATASET="ERA5"
VAR_LIST="msl u10 v10"
DOMAIN_LIST="AFR AUS CAM EAS EUR NAM SAM WAS"

ANO_I=2000
ANO_F=2009 

for DOMAIN in ${DOMAIN_LIST[@]}; do
	
    DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/TRACK-CYCLONE/CORDEX-TF/${DATASET}/S2R-Vortrack/${DOMAIN}/postproc"

    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}

    for VAR in ${VAR_LIST[@]}; do
        for YR in $(seq $ANO_I $ANO_F); do
            CDO selyear,$YR ${VAR}_${DATASET}_6hr_2000-2009_smooth2.nc ${VAR}_${DATASET}_6hr_${YR}.nc
   	
	    for HR in 00 06 12 18; do
                CDO selhour,$HR ${VAR}_${DATASET}_6hr_${YR}.nc ${VAR}.${YR}.${HR}.nc
	    done		
	done
    done
done

}


