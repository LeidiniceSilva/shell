#!/bin/bash
#SBATCH -N 1 
#SBATCH -t 8:00:00
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=ggiulian@ictp.it
#SBATCH -p skl_usr_prod

source /marconi/home/userexternal/ggiulian/STACK22/env2022

##############################
### change inputs manually ###
##############################

n=$1
path=$2-$1
export snum=$1
export conf=$2
export rdir=$3      #/marconi_scratch/userexternal/jciarlo0/ERA5
scrdir=$4    #/marconi/home/userexternal/jciarlo0/regcm_tests/Atlas2
export ys=$5 #1999-1999

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

#vars="rsnl"
vars="rsnl pr tas tasmax tasmin clt"
#vars="pr tas tasmax tasmin clt"
#vars="pr"
#if [ $n = Europe -o $n = NorthAmerica -o $n = EastAsia ]; then
#  vars="$vars snw"
#fi
for v in $vars; do
  export var=$v
  if [ $n = Europe -o $n = Europe03 ]; then
    [[ $v = pr     ]] && o="hires eobs mswep cpc gpcc era5 cru"
    [[ $v = tas    ]] && o="eobs era5 cru"
  elif [ $n = Mediterranean -o $n = SEEurope -o $n = WMediterranean ]; then
    [[ $v = pr     ]] && o="hires eobs mswep"
    [[ $v = tas    ]] && o="eobs"
  elif [ $n = EastAsia ]; then
    [[ $v = pr     ]] && o="mswep cpc gpcc aphro cn05.1 era5 cru"
    [[ $v = tas    ]] && o="cru cn05.1 aphro era5"
  else
    [[ $v = pr     ]] && o="mswep cpc gpcc cru era5"
    [[ $v = tas    ]] && o="cru era5"
  fi
  [[ $v = tasmax ]] && o="cru era5"
  [[ $v = tasmin ]] && o="cru era5"
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
    ncl -Q $scrdir/plot_4s_simple_v3.ncl
    if [ $v = pr ]; then
      export look=model
      ncl -Q $scrdir/plot_4s_pr.ncl
    fi
  fi
  # individual obs
  for this_o in $o; do
    echo "#--- plotting ${this_o^^} ---#"
    export obs=${this_o^^}
    ncl -Q $scrdir/plot_4s_simple_v3.ncl
    if [ $v = pr ]; then
      export res=0.1
      [[ $this_o = gpcc   ]] && export res=0.25
      [[ $this_o = aphro  ]] && export res=0.25
      [[ $this_o = cn05.1 ]] && export res=0.25
      [[ $this_o = cru    ]] && export res=0.5
      [[ $this_o = era5   ]] && export res=0.25
      if [ $this_o = hires ]; then
        [[ $n = Europe ]] && export res=0.11 || export res=0.03 
      fi
      export look=obs  
      ncl -Q $scrdir/plot_4s_pr.ncl
    fi
  done
done

echo "#### bias plots complete! ####"
