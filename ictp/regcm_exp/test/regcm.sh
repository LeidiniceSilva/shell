#!/bin/bash

#SBATCH -J MODEL
#SBATCH -A ICT23_ESP
#SBATCH -o logs/rcm5_SLURM.out
#SBATCH -e logs/rcm5_SLURM.err
#SBATCH -N 20
#SBATCH -t 24:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p skl_usr_prod

{
set -eo pipefail

# load required modules
module purge
source /marconi/home/userexternal/ggiulian/STACK22/env2022

nl=$1
mpirun ./bin/regcmMPICLM45_SKL $nl
}
