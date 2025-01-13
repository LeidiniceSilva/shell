#!/bin/bash

#SBATCH -N 1 
#SBATCH -t 8:00:00
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p skl_usr_prod

source /marconi/home/userexternal/ggiulian/STACK22/env2022

##############################
### change inputs manually ###
##############################

n=$1
path=$2-$1
export snum=$1
export conf=$2
rdir=$3      
scrdir=$4    
export ys=$5 

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

ncl -Q $scrdir/plot_vert.ncl
#ncl -Q $scrdir/plot_vert_daynight.ncl

echo "#### vertical plots complete! ####"
