#!/bin/bash
#SBATCH -N 1 
#SBATCH -t 0:01:00
#SBATCH -A ICT23_ESP
#SBATCH -p bdw_all_serial
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
endlog=`echo $( tail ${colog} | grep 'Successfully completed ICBC' )`
if [ -z "$taillg" ]; then
  echo '$*£&! Empty log!'
  exit 1
fi
if [ "$endlog" != "Successfully completed ICBC" ]; then
  set +e
  sstchk=$( cat $celog | grep 'No timesteps for SST' )
  set -e
  if [ ! -z $sstchk ]; then
    echo "ERROR: No timesteps for SST."
    exit 1
  fi
  echo "ERROR: ICBC ended abruptly!!!" >> $celog
  errtime=`echo $( tail -20 ${colog} | grep -i 'READ IN fields at DATE' | tail -1 ) | cut -d ' ' -f 6`
  erryr=`echo $errtime | cut -d '-' -f 1`
  errmn=`echo $errtime | cut -d '-' -f 2`
  restartdate="${erryr}${errmn}0100"
else
  restartdate=$( echo $cjn | cut -d'_' -f4 )
fi
if [ $restartdate = 0100 ]; then
  echo "ERROR: unsupported restart date 0100!"
  exit 1
fi

nl=$( echo $cjn | cut -d'_' -f2 ).in
bash submit-icbc.sh $nl $restartdate true

}
