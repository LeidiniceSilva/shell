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

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/cyclone"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_IN}
echo ${DIR_IN}

echo
echo "--------------- INIT POSPROCESSING DATASET ----------------"

#${BIN}/./regrid ${DIR_IN}/CMORPH/cmorph_SAM-3km_CMORPH_1hr_2018-2021_lonlat.nc -35.70235,-11.25009,0.22 -78.66277,-35.48362,0.22 bil
#${BIN}/./regrid ${DIR_IN}/ERA5/tp_SAM-3km_ERA5_1hr_2018-2021_lonlat.nc -35.70235,-11.25009,0.22 -78.66277,-35.48362,0.22 bil	
${BIN}/./regrid ${DIR_IN}/RegCM5/pr_SAM-3km_RegCM5_1hr_2018-2021_lonlat.nc -35.70235,-11.25009,0.22 -78.66277,-35.48362,0.22 bil
#${BIN}/./regrid ${DIR_IN}/WRF415/PREC_ACC_NC_SAM-3km_WRF415_1hr_2018-2021_lonlat.nc -35.70235,-11.25009,0.22 -78.66277,-35.48362,0.22 bil

echo
echo "--------------- THE END POSPROCESSING DATASET ----------------"

}
