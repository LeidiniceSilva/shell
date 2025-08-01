#!/bin/bash

#SBATCH -A ICT25_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1 
#SBATCH --ntasks-per-node=112
#SBATCH -o logs/icbc_SLURM.out
#SBATCH -e logs/icbc_SLURM.err
#SBATCH -J icbc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

{
source /leonardo/home/userexternal/ggiulian/modules
set -eo pipefail

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

[[ $ter = true ]] && ./bin/terrainCLM45_SKL $nnl
[[ $ter = true ]] && ./bin/mksurfdataCLM45_SKL $nnl
[[ $sst = true ]] && ./bin/sstCLM45_SKL $nnl
[[ $icb = true ]] && ./bin/icbcCLM45_SKL $nnl
echo "icbc script complete"
}
