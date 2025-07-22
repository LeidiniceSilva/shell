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

VAR="cmorph"
DATASET="CMORPH"
DOMAINS="SESA-3"

BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "Select variable"
for DOMAIN in ${DOMAINS[@]}; do

	DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS/${DATASET}"
	DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/hpe/obs/SESA-3/CMORPH"

	cd ${DIR_OUT}
	echo ${DIR_OUT}

	for YEAR in `seq -w 2000 2009`; do

		${BIN}/./regrid ${DIR_IN}/${VAR}_CSAM-3_CMORPH_1hr_${YEAR}.nc -35.25,-22.25,0.0275 -60.25,-50.25,0.0275 bil
		mv ${VAR}_CSAM-3_CMORPH_1hr_${YEAR}_lonlat.nc ${VAR}_${DOMAIN}_${DATASET}_1hr_${YEAR}_lonlat.nc

	done
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
