#!/bin/bash
#SBATCH -N 1 
#SBATCH -t 0:01:00
#SBATCH -A ICT23_ESP
#SBATCH -p skl_usr_prod
#SBATCH -o logs/control.o
#SBATCH -e logs/control.e
{
set -eo pipefail

cjn=$1
dep=$2
dpath=$( echo $nl | cut -d. -f1 )

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
# errtime=`echo $( tail -20 ${colog} | grep 'variables written at' | tail -1 ) | cut -d ' ' -f 5`
  erryr=`echo $errtime | cut -d '-' -f 1`
  errmn=`echo $errtime | cut -d '-' -f 2`
  errdy=`echo $errtime | cut -d '-' -f 3`
  restartdate="${erryr}${errmn}0100"
  echo "Unknown ERROR Detected at $errtime!" >> $celog
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

}
