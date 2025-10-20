#!/bin/bash

#SBATCH -A CMPNS_ictpclim
#SBATCH -p dcgp_usr_prod
#SBATCH -N 12
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -o logs/rcm_SLURM.out
#SBATCH -e logs/rcm_SLURM.err
#SBATCH -J CSAM-3
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

{
source /leonardo/home/userexternal/ggiulian/modules
set -eo pipefail

nl=$1
mpirun ./bin/regcmMPICLM45_cordex $nl
}
