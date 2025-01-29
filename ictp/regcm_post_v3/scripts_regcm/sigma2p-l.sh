#!/bin/bash

#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 4:00:00
#SBATCH -A ICT23_ESP_1
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p dcgp_usr_prod

# load required modules
module purge
source /leonardo/home/userexternal/ggiulian/modules

export REMAP_EXTRAPOLATE=off

{
set -eo pipefail

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
bnf=$here/bin/sigma2pCLM45
cd $pdir

[[ $t = ATM ]] && sv="clw,cli,ua,va,hus,rh,ta,wa" || sv="cl"
for f in $( \ls ../*${t}.${y}*.nc ); do
  bn=$( basename $f .nc )
  echo $bn
  if [ ! -f $pdir/${bn}_pressure.nc ]; then
    $bnf $f
  fi
done
}
