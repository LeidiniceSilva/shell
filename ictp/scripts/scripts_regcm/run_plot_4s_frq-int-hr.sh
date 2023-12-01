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
export rdir=/marconi_work/ICT23_ESP/jciarlo0/WMD03/$conf
scrdir=/marconi/home/userexternal/jciarlo0/regcm_tests/Atlas2
export ys=1995-1999

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

indices="frq int"
for i in $indices; do
  export indx=$i 
echo $indx ......

vars="pr"
for v in $vars; do
  export var=$v
  if [ $n = Europe -o $n = WMediterranean -o $n = Europe03 ]; then
    o="hires"
# elif [ $n = EastAsia ]; then
#   o="cpc aphro"
  else
    echo not coded for
    exit 1
    o=cpc
  fi
  echo "#=== $v ===#"
  # all obs
  #if [[ "$o" == *" "* ]]; then
  #  echo "#--- plotting ${o^^} ---#"
  #  export obs=${o^^}
  #  ncl -Q $scrdir/plot_4s_frq-int-hr.ncl
  #  export look=model
  #  ncl -Q $scrdir/plot_4s_frq-int-actual-hr.ncl
  #fi
  # individual obs
  for this_o in $o; do
    echo "#--- plotting ${this_o^^} ---#"
    export obs=${this_o^^}
    ncl -Q $scrdir/plot_4s_frq-int-hr.ncl
#   export look=model
#   ncl -Q $scrdir/plot_4s_frq-int-actual-hr.ncl
#   export res=0.1
#   [[ $this_o = aphro  ]] && export res=0.25
#   if [ $this_o = hires ]; then
#     [[ $n = Europe ]] && export res=0.11 || export res=0.03
#   fi
#   export look=obs
#   ncl -Q $scrdir/plot_4s_frq-int-actual-hr.ncl
  done
done

done

echo "#### bias plots complete! ####"
