#!/bin/bash

#SBATCH -o logs/WDM7_SLURM.out
#SBATCH -e logs/WDM7_SLURM.err
#SBATCH -N 8 --ntasks-per-node=48 #--mem=63G ##esp1
#SBATCH -t 24:00:00
#SBATCH -J WDM7-EUR11
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p skl_usr_prod
#SBATCH --qos=qos_prio

{

set -eo pipefail

module purge
source /marconi/home/userexternal/ggiulian/STACK22/env2022

nl=$1
#mpirun /marconi/home/userexternal/ggiulian/binaries_test/terrainCLM45_SKL $nl
#mpirun /marconi/home/userexternal/ggiulian/binaries_test/sstCLM45_SKL $nl
#mpirun /marconi/home/userexternal/ggiulian/binaries_test/icbcCLM45_SKL $nl
mpirun ./bin/regcmMPICLM45 EUR-11_WDM7.in

}
