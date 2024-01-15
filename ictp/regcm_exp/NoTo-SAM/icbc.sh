#!/bin/bash

#SBATCH -o logs/icbc_SLURM.out
#SBATCH -e logs/icbc_SLURM.err
#SBATCH -N 1 #--ntasks-per-node=20 --mem=63G ##esp1
#SBATCH -J icbc
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -A ICT23_ESP
{
set -eo pipefail

# load required modules
module purge
source /marconi/home/userexternal/ggiulian/STACK22/env2022

nl=$1
pp=$2

startDate=$3
endTarget=$4

# logical flags to choose which bins to run
ter=$5
sst=$6
icb=$7

dpath=$( echo $nl | cut -d. -f1 )
mkdir -p .${dpath}
nnl=".${dpath}/.icbc_${dpath}_${startDate}_${endTarget}.in"
cp $nl $nnl

sed -i "s/startTarget/${startDate}/g" $nnl
sed -i "s/endTarget/${endTarget}/g" $nnl

[[ $ter = true ]] && ./bin/terrainNETCDF4_HDF5_CLM45_$pp $nnl
[[ $ter = true ]] && ./bin/mksurfdataNETCDF4_HDF5_CLM45_$pp $nnl
[[ $sst = true ]] && ./bin/sstNETCDF4_HDF5_CLM45_$pp $nnl
[[ $icb = true ]] && ./bin/icbcNETCDF4_HDF5_CLM45_$pp $nnl
echo "icbc script complete"
}
