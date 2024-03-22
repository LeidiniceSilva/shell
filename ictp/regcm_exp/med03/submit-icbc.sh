#!/bin/bash

base=/marconi_scratch/userexternal/jciarlo0

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
sD="${2:-1995010100}" #start Date
cL="${3:-false}" #control Logic #false-sst-true
dep=$4

dmon=6
eT=2015010100
[[ $nl = ERA5-WMediterranean.in ]] && eT=2007010100

## check ATM
if [ $cL = true ]; then
  atmdir=$( cat $nl | grep coarse_outdir | cut -d"'" -f2 )
  atmfil=$( ls $atmdir/*ATM*.nc | tail -1 )
  atmdat=$( basename $atmfil | cut -d. -f2 )
  if [ $atmdat -lt $eT ]; then
    eT=$atmdat
  fi
fi

ter=true 
sst=false
icb=false
p=SKL

subtyp=terrain
if [ $cL = sst ]; then
  ter=false
  sst=true 
  icb=false
  p=BDW
  subtyp=sst
fi
if [ $cL = true ]; then
  ter=false
  sst=false
  icb=true
  p=SKL
  subtyp=icbc
fi
pp=""
[[ $p = BDW ]] && pp="-p bdw_all_serial -t 4:00:00"
[[ $p = SKL ]] && pp="-p skl_usr_prod -t 24:00:00"

if [ $sD -ge $eT ]; then
  echo "sD = $sD ;; eT = $eT"
  echo 'ICBC Target End Date reached successfully :)'
  exit 0
fi
yymmdd=$( echo $sD | cut -c1-8 )
eD=$(date +%Y%m%d -d "$yymmdd + $dmon months")00
[[ $eD -gt $eT ]] && eD=$eT
[[ $cL = false ]] && eD=$eT  # run all terrain in one go

#if [ $nl = MPI-WMediterranean.in -a $sD = 1997030100 ]; then
#  eD=1997110100
#fi

if [ $ter = false -a $sst = false -a $icb = false ]; then
  echo "NOTE: all logical conditions set to false."
  echo " job is irrelevant or revise logic."
  exit 1
elif [ $ter = true -a $sst = true -a $icb = false ]; then
  cL=false
  eD=$eT
elif [ $ter = true -a $sst = false -a $icb = false ]; then
  cL=false
  eD=$eT
elif [ $ter = false -a $sst = true -a $icb = false ]; then
  cL=false
  eD=$eT
fi 

#if [ $nl = ERA5-WMediterranean.in ]; then
#  sD=2001020100
#  eD=2001022818
#fi

dpath=$( echo $nl | cut -d. -f1 )
job="${subtyp}_${dpath}_${sD}_${eD}"
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
