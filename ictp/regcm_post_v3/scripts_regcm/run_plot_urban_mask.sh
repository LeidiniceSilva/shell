#!/bin/bash

#SBATCH -A ICT23_ESP_1
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1 
#SBATCH -t 4:00:00
#SBATCH --ntasks-per-node=108
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=clu@ictp.it

# module purge
source /leonardo/home/userexternal/ggiulian/modules_gfortran

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
snum2=$6 # AFR-22
ddir=$7 # icbc folder

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

#
export f=$( eval ls $ddir/${snum2}_CLM45_surface.nc )
echo $f
if [[ ! -f $f ]]; then
	echo "No CLM45 surface file."
	exit -1
fi

ncl -Q $scrdir/plot_urban_mask.ncl

echo "#### plot complete! ####"
