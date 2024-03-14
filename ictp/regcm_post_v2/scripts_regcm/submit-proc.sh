#!/bin/bash
{
set -eo pipefail

scr=$3
n=$1
c=$2
path=$2-$1

if [ $# -ne 2 ]
then
   echo "Please provide Domain name and conf name in $rdir"
   echo "Example: $0 Africa NoTo"
   exit 1
fi

p=BDW
[[ $p = BDW ]] && pp="-p bdw_all_serial" || pp="-p skl_usr_prod"
em="--mail-user=$email"

j=$( basename $scr .sh )_${path}
o=logs/${j}.out
e=logs/${j}.err
sbatch -J $j -o $o -e $e $pp $em $scr $n $c 
# jid=$( sbatch -J $j -o $o -e $e $pp $em $scr $n $c $rdir $y $t $p | cut -d' ' -f4 )
# echo "Submitted $y $t sigma2p with job-i.d. $jid"
}
