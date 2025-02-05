#!/bin/bash

#SBATCH -A ICT23_ESP_1
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1 
#SBATCH -t 4:00:00
#SBATCH --ntasks-per-node=108
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it

# module purge
source /leonardo/home/userexternal/ggiulian/modules_gfortran

##############################
### change inputs manually ###
##############################

n=$1
path=$2-$1
export snum=$1
export conf=$2
export rdir=$3     
export scrdir=$4   
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

indices="frq int"
for i in $indices; do
  export indx=$i 

vars="pr"
for v in $vars; do
  export var=$v
  if [ $n = Europe -o $n = WMediterranean -o $n = Europe03 ]; then
    o="eobs cpc gpcc"
  else
    o="cpc gpcc"
  fi
  echo "#=== $v ===#"
  [[ $fyr -lt 1979 ]] && o=${o//cpc/}
  [[ $fyr -lt 1979 ]] && o=${o//mswep/}
  [[ $fyr -lt 1982 ]] && o=${o//gpcc/}
  # all obs
   if [[ "$o" == *" "* ]]; then
     echo "#--- plotting ${o^^} ---#"
     export obs=${o^^}
     ncl -Q $scrdir/plot_4s_frq-int.ncl
#    export look=model
#    ncl -Q $scrdir/plot_4s_frq-int-actual.ncl
   fi
  # individual obs
  for this_o in $o; do
    echo "#--- plotting ${this_o^^} ---#"
    export obs=${this_o^^}
    ncl -Q $scrdir/plot_4s_frq-int.ncl
#   export res=0.1
#   [[ $this_o = aphro  ]] && export res=0.25
#   [[ $this_o = gpcc   ]] && export res=0.25
#   if [ $this_o = hires ]; then
#     [[ $n = Europe ]] && export res=0.11 || export res=0.03
#   fi
#   export look=obs
#   ncl -Q $scrdir/plot_4s_frq-int-actual.ncl
  done
done

done

echo "#### bias plots complete! ####"
