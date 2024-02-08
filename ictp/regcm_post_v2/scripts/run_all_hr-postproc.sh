#!/bin/bash

#SBATCH -N 1 
#SBATCH -t 4:00:00
#SBATCH -A ICT23_ESP
#SBATCH -p skl_usr_prod

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

##############################
### change inputs manually ###
##############################

#if [ $# -ne 2 ]
#then
#   echo "Please provide Domain name and conf name in $rdir"
#   echo "Example: $0 Africa NoTo"
#   exit 1
#fi

this_domain=$1
this_config=$2
dep="" 
n=$this_domain
[[ $n = Europe ]] && domdir=EUR11
[[ $n = WMediterranean ]] && domdir=WMD03

export rdir=/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km
yrs=2018-2021
email="mda_silv@ictp.it"
run_postproc="2 2 2 2" 
#1/0 = on/off switch for pdfs, pr-frq/int, p99, DiurnalCycle
#2 = on but submitted as a job. 

##############################
####### end of inputs ########
##############################

export odir=$rdir/obs
hdir=/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts_regcm

cp=false
if [ $n = Europe03 -o $n = WMediterranean ]; then
  cp=true
fi
if [ $cp = false ]; then
  echo "ERROR. This script is to be used by CP simulations only"
#  exit 1
fi

set -eo pipefail
# postproc files
mn=postproc # main script name
postproc=("${mn}_pdfs-hr" "${mn}_frq-int-hr" "${mn}_p99-hr" "${mn}_DiurnalCycle")
nrun=$(( ${#postproc[@]} - 1 ))

export n=$this_domain
export path=$this_config-$this_domain
export dom=$this_domain
export snam=$this_config-$this_domain
export ys=$yrs
export tper=$yrs
export yr=$yrs
conf=$this_config

mkdir -p logs
for i in `seq 0 $nrun`; do
  id=$(( $i * 2 ))
  this_run=${run_postproc:$id:1}
  this_postproc=${postproc[i]}
# echo $this_run
  if [ $this_run -eq 1 ]; then
    echo Running $this_postproc $this_domain $this_config $yrs
    bash $hdir/${this_postproc}.sh $dom $conf $rdir $odir $yrs $hdir # $ltemp
  elif [ $this_run -eq 2 ]; then
    scr=$hdir/${this_postproc}.sh
    em="--mail-user=$email"
    pr="--qos=qos_prio"
    j=${this_postproc}_${dom}_${this_config}_${yrs}
    o=logs/${j}.out
    e=logs/${j}.err
    sbatch $em -J $j -o $o -e $e $pr $dep $scr $dom $conf $rdir $odir $yrs $hdir
  fi
done

}
