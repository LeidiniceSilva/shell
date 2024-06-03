#!/bin/bash

#SBATCH -t 00:20:00
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH --qos=qos_prio
#SBATCH -p skl_usr_prod

nl=$1
gcm=$( echo $nl | cut -d- -f1 )
sim=$( basename $nl .in )
datadir=/marconi/home/userexternal/mdasilva/user/mdasilva/CORDEX/$gcm/$sim
idate=$2

pycordex=/marconi/home/userexternal/mdasilva/github_projects/pypostdoc/pycordexer
mail="coppolae@ictp.it"
domain=CSAM-3
global=ERA5
[[ $gcm = ERA5    ]] && global="ERA5"
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
regcm_version_id='v1-r1'
srfvars=ts,prhmax,prsn,tauu,tauv,zmla,prw,rsus,rlus,hfss,hfls
srfvars=$srfvars,ua50m,ua100m,ua150m,va50m,va100m,va150m,ta50m,hus50m
srfvars=$srfvars,mrros,mrro
radvars=clwvi,clivi,rlut,rsut,rsdt
stsvars=sfcWindmax,sund
atmvars=ua,va,ta,hus,zg,wa,mrsol,mrso,tsl

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
	--regcm-version-id $regcm_version_id $radfile $radvars
$pycordex/pycordexer.py \
	-m $mail -d $domain -g $global -e $experiment -b $ensemble \
	-n "$notes" -o $output -p $proc -r $regcm_release \
	--regcm-version-id $regcm_version_id $stsfile $stsvars
$pycordex/pycordexer.py \
	-m $mail -d $domain -g $global -e $experiment -b $ensemble \
	-n "$notes" -o $output -p $proc -r $regcm_release \
	--regcm-version-id $regcm_version_id $atmfile $atmvars
}

mondir=$output/output/$domain/ICTP/$global/$experiment/$ensemble
mondir=$mondir/ICTP-RegCM$regcm_release/$regcm_version_id/mon

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
