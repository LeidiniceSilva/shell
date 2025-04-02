#!/bin/bash

#SBATCH --account             ICT25_ESP
#SBATCH --job-name            CSAM-3_POST
#SBATCH --mail-type           ALL
#SBATCH --mail-user           mda_silv@ictp.it
#SBATCH --nodes               1
#SBATCH --ntasks-per-node     64
#SBATCH --partition           dcgp_usr_prod
#SBATCH --time                1-00:00:00

datadir=$1
idate=$2

pycordex=/leonardo/home/userexternal/ggiulian/RegCM-CORDEX5/Tools/Scripts/pycordexer
mail=mda_silv@ictp.it
domain=CSAM-3
global=ERA5
experiment=evaluation
ensemble=r0i0p0f0
notes="None"
output="."
proc=64
regcm_release=5.0.0
regcm_version_id=v1-r1
srfvars=cape,cin,li,evspsblpot,z0,hfso
radvars=clh,clm,cll
stsvars=wsgsmax

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
#$pycordex/pycordexer.py \
#	-m $mail -d $domain -g $global -e $experiment -b $ensemble \
#	-n "$notes" -o $output -p $proc -r $regcm_release \
#	--regcm-version-id $regcm_version_id $atmfile $atmvars
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
  $pycordex/means.py ../../day/$var/* mon
  cd ../
done

cd $dirnow
