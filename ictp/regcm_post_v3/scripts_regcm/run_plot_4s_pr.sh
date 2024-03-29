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
rdir=/marconi/home/userexternal/mdasilva/user/mdasilva/EUR-11
scrdir=/marconi/home/userexternal/jciarlo0/regcm_tests/Atlas2
export ys=2000-2001

##############################
####### end of inputs ########
##############################

if [ $# -ne 2 ]
then
   echo "Please provide Domain name and conf name in $rdir"
   echo "Example: $0 Africa NoTo"
   exit 1
fi

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

looks="obs model"
for l in $looks; do
  export look=$l

vars="pr"
for v in $vars; do
  export var=$v
  if [ $n = Mediterranean -o $n = SEEurope -o $n = WMediterranean ]; then
    [[ $v = pr     ]] && o="eobs mswep hires"
  fi
  echo "#=== $v ===#"
  # all obs
  if [ $l = model ]; then
  if [[ "$o" == *" "* ]]; then
    echo "#--- plotting ${o^^} ---#"
    export obs=${o^^}
    ncl -Q $scrdir/plot_4s_pr.ncl
  fi
  fi
  if [ $l = obs ]; then
  # individual obs
  for this_o in $o; do
    echo "#--- plotting ${this_o^^} ---#"
    export res=0.1
    [[ $this_o = hires ]] && export res=0.03
    export obs=${this_o^^}
    ncl -Q $scrdir/plot_4s_pr.ncl
  done
  fi
done

done

echo "#### bias plots complete! ####"
