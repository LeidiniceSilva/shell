#!/bin/bash

#SBATCH -J ICBC
#SBATCH -A ICT23_ESP
#SBATCH -o logs/icbc_SLURM.out
#SBATCH -e logs/icbc_SLURM.err
#SBATCH -N 1 
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mda_silv@ictp.it

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

[[ $ter = true ]] && ./bin/terrainCLM45_$pp $nnl
[[ $ter = true ]] && ./bin/mksurfdataCLM45_$pp $nnl
[[ $sst = true ]] && ./bin/sstCLM45_$pp $nnl
[[ $icb = true ]] && ./bin/icbcCLM45_$pp $nnl

echo "icbc script complete"
}
