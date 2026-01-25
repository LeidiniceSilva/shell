#!/bin/bash

base=/leonardo/home/userexternal/mdasilva/leonardo_scratch/SAM-3km

{
set -eo pipefail

echo $#
if [ $# -lt 1 ]
then
  echo $0: Not enough arguments.
  echo $0: Need at least namelist file.
  echo $0: START DATE : YYYYMMDD00 - default 2018010100
  echo $0: DEPENDENCY : -d afterany:JOBID
  echo $0: Example:
  echo $0 namelist.in [YYYYMMDD00] [dep]
  exit 1
fi

nl=$1 #namelist
startDate="${2:-2018010100}" #start Date
dep=$3

dpath=$( echo $nl | cut -d. -f1 )

nnod=16
dmon=2

driv=$( echo $nl | cut -d- -f1 )
tdir=$base/$dpath
mkdir -p $tdir

startTarget=2018010100
  endTarget=2022010100
[[ $startDate -eq $startTarget ]] && newsim=true || newsim=false
if [ $startDate -lt $startTarget ]; then
  echo "ERROR! startDate < startTarget"
  echo "  startDate must be greater or equal to startTarget!"
  echo "  startDate  : $startDate"
  echo "  startTarget: $startTarget"
  exit 1
elif [ $startDate -ge $endTarget ]; then
  echo 'Simulation Target End Date reached successfully :)'
  exit 0
fi

if [ $newsim = true ]; then
  restLogic=".false."
else
  restLogic=".true."
fi
yymmdd=$( echo $startDate | cut -c1-8 )
endDate=$(date +%Y%m%d -d "$yymmdd + $dmon months")00
endDate=$( echo $endDate | cut -c1-6 )0100
[[ $endDate -gt $endTarget ]] && endDate=$endTarget

mkdir -p .${dpath}
nnl=".${dpath}/.${dpath}_${startDate}_${endDate}.in"
cp $nl $nnl

sed -i "s/restLogic/${restLogic}/g" $nnl
sed -i "s/startTarget/${startTarget}/g" $nnl
sed -i "s/startDate/${startDate}/g" $nnl
sed -i "s/endTarget/${endTarget}/g" $nnl
sed -i "s/endDate/${endDate}/g" $nnl
sed -i "s/dpath/${dpath}/g" $nnl

job="${dpath}_${startDate}_${endDate}"
o="logs/${job}.out"
e="logs/${job}.err"

echo "
    #### SUBMITTING NEW SIMULATION ####
sim-id    : ${dpath}
startTarg : $startTarget
startDate : $startDate
endDate   : $endDate
restLogic : $restLogic
dependency: $dep

SUBMIT command:
sbatch -J $job -o $o -e $e $dep regcm.sh $nnl"

#echo "OK? [ENTER] to go on, [CTRL+C] to stop"
#read

jid=$( sbatch -N $nnod -J $job -o $o -e $e $dep regcm.sh $nnl | cut -d' ' -f4 )
echo "Submitted simulation with job i.d. $jid !!!"

cj=ctrl_${job}
o=logs/${cj}.out
e=logs/${cj}.err
cid=$( sbatch -J $cj -o $o -e $e -d afterany:$jid control-regcm.sh $job | cut -d' ' -f4 )
echo "Submitted control with job i.d. $cid !!!"
}
