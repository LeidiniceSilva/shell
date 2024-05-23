#!/bin/bash
#SBATCH -t 01:00:00
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH --qos=qos_prio
#SBATCH -p skl_usr_prod

nl=$1
gcm=$( echo $nl | cut -d- -f1 )
sim=$( basename $nl .in )
datadir=/marconi_work/ICT23_ESP/jdeleeuw/CORDEX/$gcm/$sim
idate=$2

pycordex=/marconi/home/userexternal/ggiulian/pycordexer
mail="mda_silv@ictp.it;coppolae@ictp.it"
domain=CSAM-3
global=ECMWF-ERA5
[[ $gcm = ERA5    ]] && global="ECMWF-ERA5"
[[ $gcm = MPI     ]] && global="DKRZ-MPI-ESM1-2-HR"
[[ $gcm = EcEarth ]] && global="EC-Earth-Consortium-EC-Earth3-Veg"
[[ $gcm = NorESM  ]] && global="NCC-NorESM2-MM"
experiment=evaluation
ensemble=r1i1p1f1
if [ $gcm != ERA5 ]; then
  [[ $sD -ge 2015010100 ]] && experiment=ssp370 || experiment="historical"
  ensemble="r1i1p1f1"
fi
notes="None"
output="."
proc=20
regcm_release=5
regcm_version_id=0
srfvars=tas,pr,evspsbl,huss,hurs,ps,psl,sfcWind,uas,vas,clt,rsds,rlds
stsvars=prmean,psmean,tasmean,tasmax,tasmin

set -e
{
srffile=$datadir/*_SRF.${idate}*.nc
stsfile=$datadir/*_STS.${idate}*.nc
radfile=$datadir/*_RAD.${idate}*.nc
atmfile=$datadir/*_ATM.${idate}*.nc
$pycordex/pycordexer.py \
	-m $mail -d $domain -g $global -e $experiment -b $ensemble \
	-n "$notes" -o $output -p $proc -r $regcm_release \
	--regcm-version-id $regcm_version_id $srffile $srfvars
$pycordex/pycordexer.py \
	-m $mail -d $domain -g $global -e $experiment -b $ensemble \
	-n "$notes" -o $output -p $proc -r $regcm_release \
	--regcm-version-id $regcm_version_id $stsfile $stsvars
}

mondir=$output/output/$domain/ICTP/$global/$experiment/$ensemble
mondir=$mondir/ICTP-RegCM$regcm_release/v$regcm_version_id/mon

dirnow=$PWD
mkdir -p $mondir && cd $mondir
for vars in ../day/*
do
  var=`basename $vars`
  mkdir -p $var
  cd $var
  $pycordex/means.py ../../day/$var/*
  cd ../
done

cd $dirnow
