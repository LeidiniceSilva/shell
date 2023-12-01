#!/bin/bash

source /marconi/home/userexternal/ggiulian/STACK22/env2022

##############################
### change inputs manually ###
##############################

n=$1
c=$2
path=$2-$1
rdir=$3   #/marconi_scratch/userexternal/jciarlo0/ERA5
ys=$5     #2000-2004
scrdir=$6 #/marconi/home/userexternal/jciarlo0/regcm_tests/Atlas2
email=$7
## exported from master script
#lgc_vert=true
#lgc_dynt=true
#lgc_quv=true
dep=""

##############################
####### end of inputs ########
##############################

export REMAP_EXTRAPOLATE=off

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

#if [ $# -ne 2 ]
#then
#   echo "Please provide Domain name and conf name in $rdir"
#   echo "Example: $0 Africa NoTo"
#   exit 1
#fi

hdir=$rdir/$path
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

fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )

p=SKL
[[ $p = BDW ]] && pp="-p bdw_all_serial" || pp="-p skl_usr_prod"
em="--mail-user=$email"

typs="RAD ATM" #ATM should be last
for t in $typs ; do
  for y in $( seq $fyr $lyr ); do
    scr=$scrdir/sigma2p.sh
    j=sigma2p_${path}_${y}_$t
    o=logs/${j}.out
    e=logs/${j}.err
    jid=$( sbatch -J $j -o $o -e $e $pp $em $dep $scr $n $c $rdir $y $t $p | cut -d' ' -f4 )
    echo "Submitted $y $t sigma2p with job-i.d. $jid"
  done
done 

if [ $lgc_vert = true ]; then
  scr=$scrdir/postproc_vert.sh
  dep="-d afterok:$jid"
  j=postproc_vert_${n}_${c}_${ys}
  o=logs/${j}.out
  e=logs/${j}.err
  jid=$( sbatch $em -J $j -o $o -e $e $dep $scr $n $c $rdir NA $ys | cut -d' ' -f4 )
  echo "Submitted $y postproc_vert with job-i.d. $jid"
fi

if [ $lgc_dynt = true ]; then
  scr=$scrdir/postproc_vert_daynight.sh
  dep="-d afterok:$jid"
  j=postproc_vert_daynight_${n}_${c}_${ys}
  o=logs/${j}.out
  e=logs/${j}.err
  jid=$( sbatch $em -J $j -o $o -e $e $dep $scr $n $c $rdir NA $ys | cut -d' ' -f4 )
  echo "Submitted $y postproc_vert_daynight with job-i.d. $jid"
fi

if [ $lgc_quv = true ]; then
  scr=$scrdir/postproc_quv.sh
  dep="-d afterok:$jid"
  j=postproc_quv_${n}_${c}_${ys}
  o=logs/${j}.out
  e=logs/${j}.err
  jid=$( sbatch $em -J $j -o $o -e $e $dep $scr $n $c $rdir NA $ys | cut -d' ' -f4 )
  echo "Submitted $y postproc_quv with job-i.d. $jid"
fi

} 
