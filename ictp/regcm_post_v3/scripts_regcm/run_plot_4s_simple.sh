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

vars="rsnl pr tas tasmax tasmin clt"

#if [ $n = Europe -o $n = NorthAmerica -o $n = EastAsia ]; then
#  vars="$vars snw"
#fi

for v in $vars; do
  export var=$v
  if [ $n = Europe -o $n = Europe03 ]; then
    [[ $v = pr     ]] && o="eobs cru gpcp gpcc cpc mswep era5"
    [[ $v = tas    ]] && o="eobs era5 cru"
  elif [ $n = Mediterranean -o $n = SEEurope -o $n = WMediterranean ]; then
    [[ $v = pr     ]] && o="hires eobs"
    [[ $v = tas    ]] && o="eobs"
  else
    [[ $v = pr     ]] && o="cru gpcp gpcc cpc mswep era5"
    [[ $v = tas    ]] && o="era5 cru"
  fi
  [[ $v = tasmax ]] && o="cru"
  [[ $v = tasmin ]] && o="cru"
  [[ $v = clt    ]] && o="cru era5"
  [[ $v = snw    ]] && o=swe
  [[ $v = rsnl   ]] && o=era5
  echo "#=== $v ===#"
  [[ $fyr -lt 1979 ]] && o=${o//cpc/} 
  [[ $fyr -lt 1979 ]] && o=${o//mswep/}
  # all obs
  if [[ "$o" == *" "* ]]; then
    echo "#--- plotting ${o^^} ---#"
    export obs=${o^^}
    ncl -Q $scrdir/plot_4s_simple.ncl
  fi
  # check model
  if [ $v = tas -o $v = tasmax -o $v = tasmin ]; then
    export look=model
    ncl -Q $scrdir/plot_4s_tas.ncl
  fi
  # individual obs
  for this_o in $o; do
    echo "#--- plotting ${this_o^^} ---#"
    export obs=${this_o^^}
    ncl -Q $scrdir/plot_4s_simple.ncl
#    if [ $v = pr ]; then
#      export res=0.1
#      [[ $this_o = gpcc   ]] && export res=0.25
#      [[ $this_o = aphro  ]] && export res=0.25
#      [[ $this_o = cn05.1 ]] && export res=0.25
#      [[ $this_o = cru    ]] && export res=0.5
#      [[ $this_o = era5   ]] && export res=0.25
#      if [ $this_o = hires ]; then
#        [[ $n = Europe ]] && export res=0.11 || export res=0.03 
#      fi
#      export look=obs  
#      ncl -Q $scrdir/plot_4s_pr.ncl
#    fi
  done
done

echo "#### bias plots complete! ####"
