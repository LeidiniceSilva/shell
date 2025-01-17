#!/bin/bash

#SBATCH -t 00:02:00
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL
#SBATCH --qos=qos_prio
#SBATCH -p skl_usr_prod

#################
##### input #####
#################

#nl=$1
gcm=$1 # $( echo $nl | cut -d- -f1 )
config=$2
domain=$3 # CSAM-3
sim="${config}-${domain}" # $( basename $nl .in )
datadir=$4 
idate=$5 # $2
mail=$6 # "mda_silv@ictp.it"
experiment=$7
ensemble=$8
notes=$9
output=${10}
proc=${11} # 20
regcm_release=${12}
regcm_version_id=${13} # 0 # 'v1-r1'

pycordex=/leonardo/home/userexternal/ggiulian/RegCM-CORDEX5/Tools/Scripts/pycordexer

########################
##### end of input #####
########################

global=$gcm
[[ $gcm = ERA5    ]] && global="ERA5"
[[ $gcm = MPI     ]] && global="DKRZ-MPI-ESM1-2-HR"
[[ $gcm = EcEarth ]] && global="EC-Earth-Consortium-EC-Earth3-Veg"
[[ $gcm = NorESM  ]] && global="NCC-NorESM2-MM"
#experiment=evaluation
#ensemble=r1i1p1f1
if [ $gcm != ERA5 ]; then
  [[ $sD -ge 2015010100 ]] && experiment=ssp370 || experiment="historical"
  ensemble="r1i1p1f1"
fi
#notes="None"
#output="."
#proc=40 # 20
#regcm_release=5
#regcm_version_id=0 # 'v1-r1'
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

#mondir=$output/output/$domain/ICTP/$global/$experiment/$ensemble
#mondir=$mondir/ICTP-RegCM$regcm_release/v$regcm_version_id/mon
#
#dirnow=$PWD
#mkdir -p $mondir && cd $mondir
#for vars in ../day/*
#do
#  var=`basename $vars`
#  mkdir -p $var
#  cd $var
#  $pycordex/means.py ../../day/$var/*
#  cd ../
#done

cd $dirnow
