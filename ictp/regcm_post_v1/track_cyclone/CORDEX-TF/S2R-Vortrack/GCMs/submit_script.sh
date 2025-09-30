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

VAR_LIST="ps ua"
GCM_LIST="NorESM2-MM"

echo "--------------- INIT POSPROCESSING DATASET ----------------"

for GCM in ${GCM_LIST[@]}; do
    for VAR in ${VAR_LIST[@]}; do

	DIR_IN="/leonardo_work/ICT25_ESP/RCMDATA/cmip6/cmip6/CMIP/NCC/NorESM2-MM/historical/r1i1p1f1/6hrLev/${VAR}/gn/v20191108"
        DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/TRACK-CYCLONE/CORDEX-TF/${GCM}/S2R-Vortrack"

	echo
	echo "Processing file"
	if [ ${VAR} == 'ps' ]
	then
	cp ${DIR_IN}/ps_6hrLev_NorESM2-MM_historical_r1i1p1f1_gn_200001010300-200912312100.nc ${DIR_OUT}
	else
	python3 comp_sigam2plev.py
	fi

    done
done
    
echo
echo "--------------- THE END POSPROCESSING DATASET ----------------"

}
