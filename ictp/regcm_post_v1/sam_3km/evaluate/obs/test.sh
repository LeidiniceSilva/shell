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

CDO mergetime swvl1_ERA5_1hr_2018.nc swvl1_ERA5_1hr_2019.nc swvl1_ERA5_1hr_2020.nc swvl1_ERA5_1hr_2021.nc swvl1_ERA5_1hr_2018-2021.nc
CDO mergetime swvl2_ERA5_1hr_2018.nc swvl2_ERA5_1hr_2019.nc swvl2_ERA5_1hr_2020.nc swvl2_ERA5_1hr_2021.nc swvl2_ERA5_1hr_2018-2021.nc
CDO mergetime swvl3_ERA5_1hr_2018.nc swvl3_ERA5_1hr_2019.nc swvl3_ERA5_1hr_2020.nc swvl3_ERA5_1hr_2021.nc swvl3_ERA5_1hr_2018-2021.nc
CDO mergetime swvl4_ERA5_1hr_2018.nc swvl4_ERA5_1hr_2019.nc swvl4_ERA5_1hr_2020.nc swvl4_ERA5_1hr_2021.nc swvl4_ERA5_1hr_2018-2021.nc

CDO mergetime u10max_ERA5_day_2018.nc u10max_ERA5_day_2019.nc u10max_ERA5_day_2020.nc u10max_ERA5_day_2021.nc u10m_ERA5_day_2018-2021.nc
CDO mergetime v10max_ERA5_day_2018.nc v10max_ERA5_day_2019.nc v10max_ERA5_day_2020.nc v10max_ERA5_day_2021.nc v10m_ERA5_day_2018-2021.nc

CDO chname,u10,u10max u10m_ERA5_day_2018-2021.nc u10max_ERA5_day_2018-2021.nc
CDO chname,v10,v10max v10m_ERA5_day_2018-2021.nc v10max_ERA5_day_2018-2021.nc

echo "--------------- THE END POSPROCESSING DATASET ----------------"

}
