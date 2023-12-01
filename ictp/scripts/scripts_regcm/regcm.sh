#!/bin/bash
#SBATCH -o logs/rcm5_SLURM.out
#SBATCH -e logs/rcm5_SLURM.err
#SBATCH -N 4 ##--ntasks-per-node=20 #--mem=63G ##esp1
#SBATCH -t 24:00:00
#SBATCH -J EUR-R5
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=jciarlo@ictp.it
#SBATCH -p skl_usr_prod
{
set -eo pipefail

module purge
source /marconi/home/userexternal/ggiulian/STACK22/env2022

nl=$1
mpirun ./bin/regcmMPINETCDF4_HDF5_CLM45_SKL $nl
}
