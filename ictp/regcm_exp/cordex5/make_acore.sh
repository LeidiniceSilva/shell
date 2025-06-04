#!/bin/bash

#SBATCH --account             ICT25_ESP
#SBATCH --job-name            PyCordex
#SBATCH --mail-type           FAIL
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
proc=20
regcm_release=5.0
regcm_version_id=v1-r1
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

#dirnow=$PWD

#daydir=$output/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r0i0p0f0/RegCM5-0/v1-r1/day
#mondir=$output/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r0i0p0f0/RegCM5-0/v1-r1/mon

#mkdir -p $mondir && cd $mondir || exit 1
#for vars in "$daydir"/*; do
#  var=$(basename "$vars")
#  mkdir -p "$var"
#  cd "$var" || continue
#  python3 $pycordex/means.py "$daydir/$var"/* .
#  cd ../
#done

#cd $dirnow
