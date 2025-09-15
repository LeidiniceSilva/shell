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
YR="2000-2009"
VAR_LIST="msl u10 v10"
DOMAIN_LIST="AFR AUS CAM EAS EUR NAM SAM WAS"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/TRACK-CYCLONE/CORDEX-TF/${DATASET}/S2R-Vortrack"
REMAP="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v1/track_cyclone/CORDEX-TF/S2R-Vortrack/Mask"

echo
echo "--------------- INIT POSPROCESSING DATASET ----------------"

for DOMAIN in ${DOMAIN_LIST[@]}; do

    DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/TRACK-CYCLONE/CORDEX-TF/${DATASET}/S2R-Vortrack/${DOMAIN}/postproc"

    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}

    for VAR in ${VAR_LIST[@]}; do

	echo
	echo "Regrid and smooth"
	CDO remapbil,${REMAP}/grid_${DOMAIN}.txt ${DIR_IN}/${VAR}_${DATASET}_${YR}.nc ${VAR}_${DATASET}_6hr_${YR}_lonlat.nc
	CDO smooth ${VAR}_${DATASET}_6hr_${YR}_lonlat.nc ${VAR}_${DATASET}_6hr_${YR}_smooth.nc
	CDO smooth ${VAR}_${DATASET}_6hr_${YR}_smooth.nc ${VAR}_${DATASET}_6hr_${YR}_smooth2.nc

    done
done
    
echo
echo "--------------- THE END POSPROCESSING DATASET ----------------"

}
