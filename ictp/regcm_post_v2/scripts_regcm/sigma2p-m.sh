#!/bin/bash

#SBATCH -N 1 
#SBATCH -t 4:00:00
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL
#SBATCH --qos=qos_prio

# load required modules
module purge
source /marconi/home/userexternal/ggiulian/STACK22/env2022

export REMAP_EXTRAPOLATE=off

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

n=$1
path=$2-$1
rdir=$3
y=$4
t=$5
p=$6

hdir=$rdir/$path
pdir=$hdir/pressure
mkdir -p $pdir

here=$( pwd )
bnf=$here/bin/sigma2pNETCDF4_HDF5_CLM45_${p}
cd $pdir

[[ $t = ATM ]] && sv="clw,cli,ua,va,hus,rh,ta,wa" || sv="cl"
for f in $( \ls ../*${t}.${y}12*.nc ); do
  bn=$( basename $f .nc )
  echo $bn
  $bnf $f
  CDO selvar,$sv $pdir/${bn}_pressure.nc $pdir/${bn}_tmp.nc
  mv $pdir/${bn}_tmp.nc $pdir/${bn}_pressure.nc
done
}
