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

GCM="NorESM-2MM" # EC-Earth3-Veg MPI-ESM1-2-HR NorESM-2MM
VAR_LIST="psl uas vas"
DOMAIN_LIST="AUS CAM EUR NAM SAM WAS"

ANO_I=2000
ANO_F=2009 

for DOMAIN in ${DOMAIN_LIST[@]}; do
	
    DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/TRACK-CYCLONE/CORDEX-TF/GCMs/${GCM}/S2R-Vortrack/${DOMAIN}/postproc"

    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}

    for VAR in ${VAR_LIST[@]}; do
        for YR in $(seq $ANO_I $ANO_F); do
            CDO selyear,$YR ${VAR}_${GCM}_6hr_2000-2009_smooth2.nc ${VAR}_${GCM}_6hr_${YR}.nc
   	
	    for HR in 03 09 15 21; do # 00 06 12 18; do
                CDO selhour,$HR ${VAR}_${GCM}_6hr_${YR}.nc ${VAR}.${YR}.${HR}.nc
	    done		
	done
    done
done

}


