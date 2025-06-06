#!/bin/bash

#SBATCH -A ICT23_ESP_1
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1 
#SBATCH -t 4:00:00
#SBATCH --ntasks-per-node=108
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it

{
# module purge
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

##############################
### change inputs manually ###
##############################

if [ $# -ne 2 ]
then
   echo "Please provide Domain name and conf name in $rdir"
   echo 'Example: $0 Africa NoTo' 
   exit 1
fi

this_domain=$1
this_config=$2
dep="" 
n=$this_domain
[[ $n = Europe ]] && domdir=EUR11
[[ $n = WMediterranean ]] && domdir=WMD03

# directory to RegCM output and pre-processed observation data
export rdir=/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11
export odir=/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/obs

yrs=2000-2001
email="mda_silv@ictp.it"

#run_postproc="0 1 1 1 1 0 0" # bias + pdf + pr-frq/int + p99
#run_postproc="0 1 0 0 0 0 0" # bias
#run_postproc="0 0 1 0 0 0 0" # pdf
#run_postproc="0 0 0 1 0 0 0" # pr-frq/int
#run_postproc="0 0 0 0 1 0 0" # p99
#run_postproc="2 0 0 0 0 0 0" # sigma2p
#run_postproc="0 0 0 0 0 2 2" # vert + wind
#run_postproc="0 0 0 0 0 2 0" # vert
 run_postproc="0 0 0 0 0 0 1" # wind
# 1/0 = on/off switch for sigma, bias, pr(%), prc/pr, pdfs, pr-frq/int, p99, vert, day/night, wind 
# last three are automatically switched off if submit-sigma is on
# 2 = on but submitted as a job. submit-sigma should not be 2
# true -if you want submit sigma to be followed by vert, daynight, and quv

export lgc_vert=true  #vertical
export lgc_dynt=false #day/night vertical
export lgc_quv=true   #winds

##############################
####### end of inputs ########
##############################

hdir=/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v3/scripts_regcm

cp=false
if [ $n = Europe03 -o $n = WMediterranean ]; then
  cp=true
fi

set -eo pipefail
# postproc files
mn=postproc # main script name
postproc=("submit-sigma" "${mn}" "${mn}_pdfs" "${mn}_frq-int" "${mn}_p99" "${mn}_vert" "${mn}_quv")
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
  [[ $this_postproc = "submit-sigma" ]] && sub_sig=$this_run
# echo $this_run
  post_sigma=false
  if [[ $this_run -eq 1 ]]; then
    [[ $this_postproc = ${mn}_vert ]] && post_sigma=true
    [[ $this_postproc = ${mn}_vert_daynight ]] && post_sigma=true
    [[ $this_postproc = ${mn}_quv ]] && post_sigma=true
  fi
  if [ $post_sigma = 2 ]; then
    echo "Error. Submit-sigma should not be 2"
    exit 1
  fi
  if [ $post_sigma = true -a $sub_sig -eq 1 ]; then
    this_run=0
    echo "### $this_postproc skipped because submit-sigma is set to 1"
  fi
  if [[ $this_run -eq 1 ]]; then
    if [ $this_postproc = ${mn}_prc2pr -a $cp = true ]; then
      echo "### skipping $this_postproc"
      continue
    fi
    echo Running $this_postproc $this_domain $this_config $yrs
    bash $hdir/${this_postproc}.sh $dom $conf $rdir $odir $yrs $hdir $em
  elif [[ $this_run -eq 2 ]]; then
    if [ $this_postproc = ${mn}_prc2pr -a $cp = true ]; then
      echo "### skipping $this_postproc"
      continue
    fi
    scr=$hdir/${this_postproc}.sh
    em="--mail-user=$email"
    j=${this_postproc}_${dom}_${this_config}_${yrs}
    o=logs/${j}.out
    e=logs/${j}.err
    sbatch $em -J $j -o $o -e $e $dep $scr $dom $conf $rdir $odir $yrs $hdir
  fi
done

}
