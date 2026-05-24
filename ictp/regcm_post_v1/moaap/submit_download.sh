#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -J GPM
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=mda_silv@ictp.it


{
source /leonardo/home/userexternal/ggiulian/modules_new
set -eo pipefail

python3 download_gpm_mergir.py

}
