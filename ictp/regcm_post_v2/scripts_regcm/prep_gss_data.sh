#!/bin/bash
{
set -eo pipefail

dom=$1 #EUR-11
gcm=$2 #ERA5
v=$4 #pr
q=$3 #1hr
tper=$5  # 2000-2004

if [ $# -lt 5 ]; then
  echo "Usage: $0 [dom] [gcm] [frq] [var] [time-period]"
  echo "e.g. $o EUR-11 ERA5 1hr pr 2000-2004"
  exit 1
fi

fyr=$( echo $tper | cut -d- -f1 )
lyr=$( echo $tper | cut -d- -f2 )
if [ $gcm != ERA5 ]; then
  [[ $fyr -ge 2015 ]] && exp=ssp585 || exp=historical
fi
[[ $gcm = ERA5 ]] && gstr=ECMWF-ERA5/evaluation/r1i1p1f1
[[ $gcm = MPI ]] && gstr=DKRZ-MPI-ESM1-2-HR/$exp/r1i1p1f1
[[ $gcm = NorESM ]] && gstr=NCC-NorESM2-MM/$exp/r1i1p1f1
[[ $gcm = EcEarth ]] && gstr=EC-Earth-Consortium-EC-Earth3-Veg/$exp/r1i1p1f1

sdir=/marconi_scratch/userexternal/jciarlo0/gsstmp/
ghom=/gss/gss_work/DRES_P14_3590/CORDEX/output
gdir=$ghom/$dom/ICTP/$gstr/ICTP-RegCM5-0/v0/$q/$v/

gfil=$gdir/${v}_*_{${fyr}..${lyr}}*-*.nc
eval rsync -a --progress $gfil $sdir

}
