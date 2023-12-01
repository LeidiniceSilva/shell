#!/bin/bash
#SBATCH -N 1 
#SBATCH -t 4:00:00
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=ggiulian@ictp.it
#SBATCH -p skl_usr_prod

source /marconi/home/userexternal/ggiulian/STACK22/env2022

##############################
### change inputs manually ###
##############################

ys=1970-1979
run_plots="1 1 1 1 0 0 1"
##0/1 = on/off switch: bias, pdf, p99, pr-frq/int, vertical, wind, taylor plots
#run_plots="1 0 1 0 1 0 0 0 0"

##############################
####### end of inputs ########
##############################

#plots=("4s_simple" "prpct" "p99" "prc2pr" "4s_frq-int" "pdfs" "vert" "quv" "taylor_diagram")
plots=("4s_simple" "pdfs" "p99" "4s_frq-int" "vert" "quv" "taylor_diagram")
nrun=$(( ${#plots[@]} - 1 ))

sdir=/marconi/home/userexternal/jciarlo0/regcm_tests/Atlas2

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

#export rdir=/marconi_work/ICT23_ESP/jciarlo0/EUR11/ERA5
export rdir=/marconi_work/ICT23_ESP/jciarlo0/$domdir/$2
#export rdir=/marconi_scratch/userexternal/jciarlo0/ERA5

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
  if [ $this_run -eq 1 ]; then
    if [ $this_plot = "prc2pr" -a $cp = true ]; then
      echo "### skipping $this_plot"
      continue
    fi
    nclplot $this_plot
  fi
done

