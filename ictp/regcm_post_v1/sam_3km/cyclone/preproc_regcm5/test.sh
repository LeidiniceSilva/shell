#!/bin/bash

#SBATCH -N 1
#SBATCH -t 24:00:00
#SBATCH -A ICT23_ESP
#SBATCH --qos=qos_prio
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p skl_usr_prod

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"
DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/obs/era5/era5"
cd ${DIR_IN}

${BIN}/./regrid cin_SAM-3km_ERA5_6hr_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
