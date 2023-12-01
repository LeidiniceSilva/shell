#!/bin/bash
#SBATCH -N 1 
#SBATCH -t 8:00:00
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=clu@ictp.it
#SBATCH -p skl_usr_prod

source /marconi/home/userexternal/ggiulian/STACK22/env2022

##############################
### change inputs manually ###
##############################

n=$1
path=$2-$1
export snum=$1
export conf=$2
rdir=$3      #/marconi_scratch/userexternal/jciarlo0/ERA5
export scrdir=$4    #/marconi/home/userexternal/jciarlo0/regcm_tests/Atlas2
export ys=$5 #1999-1999


plevs=(200 500 850)
# plev options: 100, 150, 200, 250, 300, 400, 500, 600, 700, 850, 925, 1000

##############################
####### end of inputs ########
##############################

#if [ $# -ne 2 ]
#then
#   echo "Please provide Domain name and conf name in $rdir"
#   echo "Example: $0 Africa NoTo"
#   exit 1
#fi

fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )

export hdir=$rdir/$path
if [ ! -d $hdir ]
then
  echo 'Path does not exist: '$hdir
  exit -1
fi

ff=$hdir/*.nc
if [ -z "$ff" ]
then
  echo 'No files: '$ff
  exit -1
fi

pdir=$hdir/plots
mkdir -p $pdir

nplev=$(( ${#plevs[@]} - 1 ))
for i in `seq 0 $nplev`; do
  export plev=${plevs[i]}

  echo Plotting wind at $plev hPa
  ncl -Q $scrdir/plot_uv.ncl
  
  echo Plotting bias in u, v, q at $plev hPa
  ncl -Q $scrdir/plot_quv_bias.ncl
done


echo "#### plot complete! ####"
