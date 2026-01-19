#!/bin/bash

#SBATCH -N 1 
#SBATCH -A CMPNS_ictpclim 
#SBATCH -p dcgp_usr_prod
#SBATCH --ntasks-per-node=108
#SBATCH -t 00:01:00
#SBATCH -o logs/control.o
#SBATCH -e logs/control.e

{
set -eo pipefail

cjn=$1
dep=$2
pycor=false

colog=logs/${cjn}.out
celog=logs/${cjn}.err
taillg=$( tail ${colog} )
endlog=`echo $( tail ${colog} | grep 'RegCM V5 simulation successfully reached end' )`
if [ -z "$taillg" ]; then
  echo '$*£&! Empty log!'
  restartdate=$( echo $cjn | cut -d_ -f2 )
fi
if [ "$endlog" != "RegCM V5 simulation successfully reached end" ]; then
  echo "ERROR: Simulation ended abruptly!!!" >> $celog
  errtime=$( cat $colog | grep -v KILLED | grep -v "BAD TERMINATION" | grep -v RANK | grep -v "==========" | tail -300 | grep 'variables written at' | tail -1 | cut -d ' ' -f 7 )
  errhour=$( cat $colog | grep -v KILLED | grep -v "BAD TERMINATION" | grep -v RANK | grep -v "==========" | tail -300 | grep 'variables written at' | tail -1 | cut -d ' ' -f 8 | cut -d':' -f1 )
# errtime=`echo $( tail -20 ${colog} | grep 'variables written at' | tail -1 ) | cut -d ' ' -f 5`
  erryr=`echo $errtime | cut -d '-' -f 1`
  errmn=`echo $errtime | cut -d '-' -f 2`
  errdy=`echo $errtime | cut -d '-' -f 3`
  restartdate="${erryr}${errmn}0100"


  set +e
  notoerrchk=$( cat $celog | grep mod_micro_nogtom.F90 | head -1 )
  qlhserrchk=$( cat $celog | grep QLHS | tail -1 )
  set -e
  if [ ! -z "$notoerrchk" -o ! -z "$qlhserrchk" ]; then
    dtval=$( cat $colog | grep "time step for dynamical" | cut -d: -f2 | cut -d' ' -f5 | \
                   cut -d. -f1 )
    echo "NOTO ERROR Detected at $errtime $errhour and dt=$dtval!" >> $celog
    newdt=$(( $dtval - 15 )) 
    dtlog=.$( echo $cjn | cut -d'_' -f1 )/.newdt
    echo $newdt > $dtlog
  else
    echo "Unknown ERROR Detected at $errtime $errhour!" >> $celog
  fi
else
  restartdate=$( echo $cjn | cut -d'_' -f3 )
fi

## find the last save file (especially important for non-monthly saves)
dompath=$( cat $colog | grep DOMAIN | head -1 )
simnm=$( echo $cjn | cut -d_ -f1 )
svdir=$( dirname $( dirname $dompath ) )/$simnm
lastsave=$( ls $svdir/*SAV.$( echo $restartdate | cut -c1-6 )*.nc | tail -1 )
restartdate=$( basename $lastsave .nc | cut -d. -f2 )
echo "Last Save is $restartdate"

nl=$( echo $cjn | cut -d'_' -f1 ).in
bash submit-regcm.sh $nl $restartdate

if [ $pycor = true ]; then
  pnl=.$( echo $cjn | cut -d_ -f1 )/.${cjn}.in
  typs="ATM RAD SRF SHF STS"
  for t in $typs; do
    pynm="py_${t}_${cjn}"
    o=logs/${pynm}.out
    e=logs/${pynm}.err
    [[ $t = ATM ]] && tl="20:00:00"
    [[ $t = RAD ]] && tl="20:00:00"
    [[ $t = SRF ]] && tl="20:00:00"
    [[ $t = SHF ]] && tl="4:00:00"
    [[ $t = STS ]] && tl="1:00:00"
    pp=""
    [[ $t = SHF ]] && pp="-p bdw_all_serial"
    [[ $t = STS ]] && pp="-p bdw_all_serial"
    dd=""
    [[ $t = SHF ]] && dd="-d afterany:$jpid"
    [[ $t = STS ]] && dd="-d afterany:$jpid"
    jpid=$( sbatch -J $pynm -o $o -e $e -t $tl $pp $dd pycordexer.sh $pnl $t | cut -d' ' -f4 )
  done
fi
}
