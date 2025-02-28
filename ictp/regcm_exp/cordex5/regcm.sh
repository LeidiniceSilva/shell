#!/bin/bash

#SBATCH -o logs/rcm_SLURM.out
#SBATCH -e logs/rcm_SLURM.err
#SBATCH -N 16 
#SBATCH --ntasks-per-node=108
#SBATCH -t 1-00:00:00
#SBATCH -J CSAM-3
#SBATCH -A ICT25_ESP
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p dcgp_usr_prod

{
source /leonardo/home/userexternal/ggiulian/modules
set -eo pipefail

nl=$1
mpirun ./bin/regcmMPICLM45 $nl
}
