#!/bin/bash

#SBATCH -o logs/rcm_SLURM.out
#SBATCH -e logs/rcm_SLURM.err
#SBATCH -N 16 ##--ntasks-per-node=20 #--mem=63G ##esp1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J CSAM-3
#SBATCH -A ICT23_ESP_1
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p dcgp_usr_prod

{
set -eo pipefail

#module purge
source /leonardo/home/userexternal/ggiulian/modules

nl=$1
mpirun ./bin/regcmMPICLM45 $nl
}
