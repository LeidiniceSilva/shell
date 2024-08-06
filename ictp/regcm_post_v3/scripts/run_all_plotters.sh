#!/bin/bash

#SBATCH -N 1 
#SBATCH -t 4:00:00
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p skl_usr_prod

source /marconi/home/userexternal/ggiulian/STACK22/env2022

##############################
### change inputs manually ###
##############################

ys=2000-2000

#run_plots="1 0 0 0 0 0 0 1 1 1" # bias + wind + taylor + pixels
#run_plots="0 0 1 0 1 0 0 0 0 0" # p99 + frq-int
#run_plots="1 1 1 1 1 1 1 1 1 1" # all
#run_plots="1 0 0 0 0 0 0 0 0"   # bias
#run_plots="0 1 0 0 0 0 0 0 0"   # %pr%
#run_plots="0 0 1 0 0 0 0 0 0"   # p99
#run_plots="0 0 0 1 0 0 0 0 0"   # prc/pr
#run_plots="0 0 0 0 1 0 0 0 0"   # frq-int
#run_plots="0 0 0 0 0 1 0 0 0"   # pdf
 run_plots="0 0 0 0 0 0 1 0 0"   # vertical
#run_plots="0 0 0 0 0 0 0 1 0"   # wind
#run_plots="0 0 0 0 0 0 0 0 1"   # taylor
#run_plots="0 0 0 0 0 0 0 0 0 1" # pixels
##0/1 = on/off switch: bias, %pr%, p99, prc/pr, pr-frq/int, pdfs, vertical, wind, taylor plots

##############################
####### end of inputs ########
##############################

plots=("4s_simple_v3" "prpct" "p99" "prc2pr_v2" "4s_frq-int" "pdfs_v2" "vert_v2" "quv" "taylor_diagram" "pixels")
nrun=$(( ${#plots[@]} - 1 ))

sdir=/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v3/scripts_regcm

if [ $# -ne 2 ]
then
   echo "Please provide Domain name and conf name in $rdir"
   echo "Example: $0 Africa NoTo"
   exit 1
fi
n=$1
path=$2-$1
export snum=$1
export conf=$2

[[ $n = Europe ]] && domdir=EUR11
[[ $n = WMediterranean ]] && domdir=WMD03

export rdir=/marconi/home/userexternal/mdasilva/user/mdasilva/EUR-11

set -eo pipefail

cp=false
if [ $n = Europe03 -o $n = WMediterranean ]; then
  cp=true
fi

nclplot(){
  bash $sdir/run_plot_${1}.sh $snum $conf $rdir $sdir $ys
}

for i in `seq 0 $nrun`; do
  id=$(( $i * 2 ))
  this_run=${run_plots:$id:1}
  this_plot=${plots[i]}
  if [[ $this_run -eq 1 ]]; then
    if [ $this_plot = "prc2pr" -a $cp = true ]; then
      echo "### skipping $this_plot"
      continue
    fi
    nclplot $this_plot
  fi
done

