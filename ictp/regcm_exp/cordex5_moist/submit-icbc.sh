#!/bin/bash

base=/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5_MOIST

{
set -eo pipefail

echo $#
if [ $# -lt 1 ]
then
  echo $0: Not enough arguments.
  echo $0: Need at least namelist file.
  echo $0: Can receive start date, terrain/icbc flag and dependency.
  echo $0: START DATE : YYYYMMDD00 - default 1999010100
  echo $0: WORK FLAG  : true icbc, false terrain/mksurfdata/sst
  echo $0: DEPENDENCY : -d afterany:JOBID
  echo $0: Example:
  echo $0 namelist.in [YYYYMMDD00] [false/true] [dep]
  exit 1
fi

nl=$1 #namelist
sD="${2:-1999010100}" #start Date
cL="${3:-false}"      #control Logic
dep=$4

dmon=12
p=USR
pp=""
[[ $p = USR ]] && pp="-p dcgp_usr_prod -t 24:00:00"
[[ $p = BDW ]] && pp="-p bdw_all_serial -t 4:00:00"
[[ $p = SKL ]] && pp="-p skl_usr_prod -t 24:00:00"

eT=2000010100
ter=true 
sst=true 
icb=false

mkdir -p $base/ERA5/icbc

if [ $cL = true ]; then
  ter=false
  sst=false
  icb=true
fi

if [ $sD -ge $eT ]; then
  echo 'ICBC Target End Date reached successfully :)'
  exit 0
fi
yymmdd=$( echo $sD | cut -c1-8 )
eD=$(date +%Y%m%d -d "$yymmdd + $dmon months")00
[[ $eD -gt $eT ]] && eD=$eT

if [ $ter = false -a $sst = false -a $icb = false ]; then
  echo "NOTE: all logical conditions set to false."
  echo " job is irrelevant or revise logic."
  exit 1
elif [ $ter = true -a $sst = true -a $icb = false ]; then
  cL=false
  eD=$eT
elif [ $ter = false -a $sst = true -a $icb = false ]; then
  cL=false
  eD=$eT
fi 

dpath=$( echo $nl | cut -d. -f1 )
job="icbc_${dpath}_${sD}_${eD}"
o="logs/${job}.out"
e="logs/${job}.err"

jid=$( sbatch -J $job -o $o -e $e $pp $dep icbc.sh $nl $p $sD $eD $ter $sst $icb | cut -d' ' -f4 )
echo "Submitted icbc with job i.d. $jid !!!"

if [ $icb = true ]; then
  cj=ctrl_${job}
  o=logs/${cj}.out
  e=logs/${cj}.err
  cid=$( sbatch -J $cj -o $o -e $e -d afterany:$jid control-icbc.sh $job | cut -d' ' -f4 )
  echo "Submitted control with job i.d. $cid !!!"
fi
}

