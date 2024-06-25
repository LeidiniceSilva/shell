#!/bin/bash

#SBATCH -o logs/rcm5_SLURM.out
#SBATCH -e logs/rcm5_SLURM.err
#SBATCH -N 30 ##--ntasks-per-node=20 #--mem=63G ##esp1
#SBATCH -t 24:00:00
#SBATCH -J CSAM-3
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p skl_usr_prod
#SBATCH --mem=177GB
#SBATCH --qos=qos_prio

{
set -eo pipefail

module purge
source /marconi/home/userexternal/ggiulian/STACK22/env2022

nl=$1
mpirun ./bin/regcmMPICLM45_SKL $nl
}
