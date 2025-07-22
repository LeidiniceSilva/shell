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
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 
{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

VAR="pr"
DATASET="COMPOSITE-ALP3"
DOMAINS="ALP-3"

BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "Select variable"
for DOMAIN in ${DOMAINS[@]}; do

	DIR_IN="/leonardo_work/ICT25_ESP/OBS/${DATASET}"
	DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/hpe/obs/${DOMAIN}/${DATASET}"

	cd ${DIR_OUT}
	echo ${DIR_OUT}

	for YEAR in `seq -w 2001 2009`; do
		for MON in `seq -w 1 12`; do
			${BIN}/./regrid ${DIR_IN}/mmhr_pr_m0_OBS_Composite_${YEAR}${MON}.nc 40,50,0.0275 1,17,0.0275 bil
		done
	echo
	echo "Merge files"
	CDO mergetime mmhr_pr_m0_OBS_Composite_${YEAR}*_lonlat.nc ${VAR}_${DOMAIN}_${DATASET}_1hr_${YEAR}_lonlat.nc

	done
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
