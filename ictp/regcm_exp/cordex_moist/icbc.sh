#!/bin/bash

#SBATCH -o logs/icbc_SLURM.out
#SBATCH -e logs/icbc_SLURM.err
#SBATCH -N 1 #--ntasks-per-node=20 --mem=63G ##esp1
#SBATCH -J icbc
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH --qos=qos_prio
#SBATCH -A ICT23_ESP
#SBATCH --mem=8GB

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
lucas=false
if [ $icb = true -a $lucas = true ]; then
  if [ $ter = true ]; then
    echo "STOP. mksurfdata with lucas runs on SKL"
    echo "      but icbc cannot run on SKL"
    echo "      run the two steps seperately"
    exit 1
  fi 
  lucas=false
fi
if [ $sst = true -a $lucas = true ]; then
  if [ $ter = true ]; then
    echo "STOP. mksurfdata with lucas runs on SKL"
    echo "      but sst cannot run on SKL"
    echo "      run the two steps seperately"
    exit 1
  fi
  lucas=false
fi

dpath=$( echo $nl | cut -d. -f1 )
mkdir -p .${dpath}
nnl=".${dpath}/.icbc_${dpath}_${startDate}_${endTarget}.in"
cp $nl $nnl

sed -i "s/startTarget/${startDate}/g" $nnl
sed -i "s/endTarget/${endTarget}/g" $nnl

#suffix=NETCDF4_HDF5_CLM45_$pp
#[[ $lucas = true ]] && suffix=NETCDF4_HDF5_CLM45_${pp}_DYNPFT
bin=bin
suffix=CLM45_$pp
[[ $lucas = true ]] && suffix=${suffix}_DYNPFT

echo "BIN = $bin"
echo "SUFFIX = $suffix"

[[ $ter = true ]] && ./$bin/terrain$suffix $nnl
[[ $ter = true ]] && ./$bin/mksurfdata$suffix $nnl
[[ $sst = true ]] && ./$bin/sst$suffix $nnl
[[ $icb = true ]] && ./$bin/icbc$suffix $nnl
echo "icbc script complete"
}
