#!/bin/bash

#SBATCH -A ICT26_ESP
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
#__description__ = 'Posprocessing the OBS with CDO'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="ERA5"
DIR_I="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS/ERA5/1hr"
DIR_II="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/ERA5"

echo
cd ${DIR_II}
echo ${DIR_II}

echo
echo "--------------- INIT POSPROCESSING ----------------"

CDO mulc,-1 avg_tnlwrf_${EXP}_1hr_2000-2009.nc avg_tnlwrf_${EXP}_reanalysis_1hr_2000-2009.nc
CDO sellonlatbox,-78.81965,-35.32753,-36.70233,-12.24439 avg_tnlwrf_${EXP}_reanalysis_1hr_2000-2009.nc avg_tnlwrf_CSAM-3_${EXP}_reanalysis_1hr_2000-2009.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}

