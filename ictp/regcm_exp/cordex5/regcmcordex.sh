#!/bin/bash

#SBATCH --account             CMPNS_ictpclim
#SBATCH --job-name            CSAM-3_POST
#SBATCH --mail-type           FAIL
#SBATCH --mail-user           mda_silv@ictp.it
#SBATCH --nodes               1
#SBATCH --ntasks-per-node     112
#SBATCH --partition           dcgp_usr_prod
#SBATCH --time                12:00:00

source $HOME/modules_new

datadir=$PWD
idates=`ls CSAM-3_SRF.${1}* | cut -d "." -f 2`

pycordex=/leonardo/home/userexternal/ggiulian/RegCM-CORDEX5/Tools/Scripts/pycordexer
mail=mda_silv@ictp.it
domain=CSAM-3
global=ERA5
experiment=evaluation
ensemble=r1i1p1f1
notes="None"
output="."
proc=20
regcm_model=RegCM
regcm_release=5.0
regcm_version_id=v1-r1

allargs="-m $mail -d $domain -g $global -e $experiment -b $ensemble \
         -n "$notes" -o $output -p $proc --regcm-model-name $regcm_model \
         -r $regcm_release --regcm-version-id $regcm_version_id"

srfvars=tas,pr,evspsbl,huss,hurs,ps,psl,sfcWind,uas,vas,clt,rsds,rlds
srfvars=$srfvars,ts,prhmax,prsn,tauu,tauv,zmla,prw,rsus,rlus,hfss,hfls
srfvars=$srfvars,ua50m,ua100m,ua150m,va50m,va100m,va150m,ta50m,hus50m
srfvars=$srfvars,mrros,mrro,cape,cin,li,evspsblpot,z0,hfso
stsvars=prmean,psmean,tasmean,tasmax,tasmin,sfcWindmax,sundmean,wsgsmax
radvars=clwvi,clivi,rlut,rsut,rsdt,clh,clm,cll
atmvars=ua,va,ta,hus,zg,wa,mrsol,mrso,tsl

for idate in $idates
do
  srffile=$datadir/*_SRF.${idate}*.nc
  stsfile=$datadir/*_STS.${idate}*.nc
  radfile=$datadir/*_RAD.${idate}*.nc
  atmfile=$datadir/*_ATM.${idate}*.nc

  pids=""
  $pycordex/pycordexer.py $allargs $srffile $srfvars & pids+="$! "
  $pycordex/pycordexer.py $allargs $radfile $radvars & pids+="$! "
  $pycordex/pycordexer.py $allargs $stsfile $stsvars & pids+="$! "
  $pycordex/pycordexer.py $allargs $atmfile $atmvars & pids+="$! "

  for p in $pids; do wait $p || err=$?; done
  [[ $err ]] && exit -1

  rm $srffile $radfile $stsfile $atmfile
done
echo Done.
