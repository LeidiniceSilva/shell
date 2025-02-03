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

# path to post-processed data
rdir=/leonardo_work/ICT24_ESP/clu/CORDEX/ERA5

# directory to <domain>_CLM45_surface.nc file (icbc folder)
ddir=/leonardo_scratch/large/userexternal/clu00000/CORDEX/ERA5/icbc

#ys=1980-2010
#ys=2000-2009
 ys=2000-2001
#ys=1971-1975
#run_plots="1 1 1 1 0 0 0" # all
#run_plots="1 0 0 0 0 0 0" # bias
#run_plots="0 1 0 0 0 0 0" # p99
#run_plots="0 0 1 0 0 0 0" # frq-int
#run_plots="0 0 0 1 0 0 0" # pdf
 run_plots="0 0 0 0 0 0 1" # urban mask
#####run_plots="0 0 0 0 1 0 0" # vert
#####run_plots="0 0 0 0 0 1 0" # wind
##0/1 = on/off switch: bias, %pr%, p99, prc/pr, pr-frq/int, pdfs, 
##                           vertical, wind, taylor plots

##############################
####### end of inputs ########
##############################

#plots=("4s_simple" "prpct" "p99" "prc2pr" "4s_frq-int" "pdfs" "vert" "quv" "taylor_diagram")
#plots=("4s_simple_v6" "prpct" "p99_v2" "prc2pr_v2" "4s_frq-int_v4" "pdfs_v4" "vert_v3" "quv" "taylor_diagram_v2" "pixels" "vert_part2" "4s_simple_v4")
plots=("4s_simple" "p99" "4s_frq-int" "pdfs" "vert" "quv" "urban_mask")
nrun=$(( ${#plots[@]} - 1 ))

# directory to scripts
sdir=/leonardo_work/ICT24_ESP/clu/RegCM_scripts/postproc_raw

if [ $# -ne 3 ]
then
   echo "Please provide Domain name and conf name in $rdir"
   echo "Example: $0 Africa NoTo AFR-22"
   exit 1
fi
n=$1
path=$2-$1
export snum=$1
export conf=$2
snum2=$3

[[ $n = Europe ]] && domdir=EUR11
[[ $n = WMediterranean ]] && domdir=WMD03

set -eo pipefail

cp=false
if [ $n = Europe03 -o $n = WMediterranean ]; then
  cp=true
fi

nclplot(){
  bash $sdir/run_plot_${1}.sh $snum $conf $rdir $sdir $ys $snum2 $ddir
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

