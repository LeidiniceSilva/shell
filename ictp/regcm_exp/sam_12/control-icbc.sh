#!/bin/bash

#SBATCH -N 1
#SBATCH -A ICT25_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH --ntasks-per-node=112
#SBATCH -t 00:01:00
#SBATCH -o logs/control.o
#SBATCH -e logs/control.e

{
set -eo pipefail

cjn=$1
fin=$2 #flag for final run
dpath=$( echo $nl | cut -d. -f1 )

colog=logs/${cjn}.out
celog=logs/${cjn}.err
taillg=$( tail ${colog} )
endlog=`echo $( tail ${colog} | grep 'Successfully completed ICBC' )`

echo "### Checking icbc for $cjn "

if [ -z "$taillg" ]; then
  echo '$*£&! Empty log!'
  exit 1
fi
set +e
ssterr=$( tail $celog | grep readsst )
set -e
if [ "$ssterr" = readsst ]; then
  echo 'SST error'
  exit 1
fi
if [ "$endlog" != "Successfully completed ICBC" ]; then
  echo "### previous icbc ended with an error"
  echo "### printing tail of output"
  tail $colog
  echo "### printing tail of error"
  tail $celog
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
  if [ $fin = true ]; then
    echo "final icbc completed"
    exit 0
  else
    restartdate=$( echo $cjn | cut -d'_' -f4 )
  fi
fi
if [ $restartdate = 0100 ]; then
  echo "WARNING: unsupported restart date 0100!"
  prevstartdate=$( echo $cjn | cut -d'_' -f3 )
  restartdate=$prevstartdate
fi

#check for infiniteloop
prevstartdate=$( echo $cjn | cut -d'_' -f3 )
if [ $prevstartdate = $restartdate ]; then
  echo "WARNING - potential infinity loop detected"
  echo "  previous start = $prevstartdate"
  echo "       new start = $restartdate"
  looplog=logs/loop_${cjn}.loop
  if [ ! -f $looplog ]; then
    echo 1 > $looplog
  else
    nlog=$( cat $looplog )
    echo $(( $nlog + 1 )) > $looplog
    echo " >>> re-attempting, n=$(( $nlog + 1 ))"
  fi
fi

nl=$( echo $cjn | cut -d'_' -f2 ).in
echo "submitting: bash submit-icbc.sh $nl $restartdate true"
bash submit-icbc.sh $nl $restartdate true
}
