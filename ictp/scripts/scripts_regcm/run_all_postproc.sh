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

if [ $# -ne 2 ]
then
   echo "Please provide Domain name and conf name in $rdir"
   echo 'Example: $0 Africa NoTo' # 2000-2001' # "0 0 0 0 1"'
   exit 1
fi
this_domain=$1
this_config=$2
dep="" #to be used only with run_postproc=2
#yrs=$3
n=$this_domain
[[ $n = Europe ]] && domdir=EUR11
[[ $n = WMediterranean ]] && domdir=WMD03

#export rdir=/marconi_work/ICT23_ESP/jciarlo0/EUR11/ERA5 
export rdir=/marconi_work/ICT23_ESP/jciarlo0/$domdir/$this_config
#export rdir=/marconi_scratch/userexternal/jciarlo0/ERA5
yrs=1995-1999
email="jciarlo@ictp.it"
#run_postproc="0 0 0 0 0 2 0 0 0 0" 
run_postproc="0 0 0 2 0 0 0"
#1/0 = on/off switch for sigma, bias, pdfs, pr-frq/int, p99, vert, wind
#      last two are automatically switched off if submit-sigma is on
#2 = on but submitted as a job. submit-sigma should not be 2
## true -if you want submit sigma to be followed by vert, daynight, and quv
export lgc_vert=true  #vertical
export lgc_dynt=false #day/night vertical
export lgc_quv=true   #winds

##############################
####### end of inputs ########
##############################

export odir=$rdir/obs
hdir=/marconi/home/userexternal/jciarlo0/regcm_tests/Atlas2

cp=false
if [ $n = Europe03 -o $n = WMediterranean ]; then
  cp=true
fi

set -eo pipefail
# postproc files
mn=postproc # main script name
#postproc=("$mn" "${mn}_pdfs" "${mn}_p99" "${mn}_vert" "${mn}_quv")
#postproc=("submit-sigma" "$mn" "${mn}_prpct" "${mn}_prc2pr" "${mn}_pdfs" "${mn}_frq-int" "${mn}_p99" "${mn}_vert" "${mn}_vert_daynight" "${mn}_quv")
postproc=("submit-sigma" "$mn" "${mn}_pdfs" "${mn}_frq-int" "${mn}_p99" "${mn}_vert" "${mn}_quv")
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
  if [ $this_run -eq 1 ]; then
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
  if [ $this_run -eq 1 ]; then
    if [ $this_postproc = ${mn}_prc2pr -a $cp = true ]; then
      echo "### skipping $this_postproc"
      continue
    fi
    em="--mail-user=$email"
    echo Running $this_postproc $this_domain $this_config $yrs
    bash $hdir/${this_postproc}.sh $dom $conf $rdir $odir $yrs $hdir $em
  elif [ $this_run -eq 2 ]; then
    if [ $this_postproc = ${mn}_prc2pr -a $cp = true ]; then
      echo "### skipping $this_postproc"
      continue
    fi
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
