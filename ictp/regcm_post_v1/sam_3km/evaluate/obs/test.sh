#!/bin/bash

#SBATCH -A ICT25_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J mergefiles
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

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS/ERA5"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING DATASET ----------------"

CDO mergetime fg10_ERA5_2018.nc fg10_ERA5_2019.nc fg10_ERA5_2020.nc fg10_ERA5_2021.nc fg10_ERA5_day_2018-2021.nc

echo "--------------- THE END POSPROCESSING DATASET ----------------"

}
