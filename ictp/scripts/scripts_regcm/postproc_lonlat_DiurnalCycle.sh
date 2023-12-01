#!/bin/bash
#SBATCH --account=ICT23_ESP
#SBATCH -N 1  
#SBATCH -t 04:00:00
#SBATCH -p bdw_all_serial
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=jciarlo@ictp.it
##############################
### change inputs manually ###
##############################

rdir=/marconi_scratch/userexternal/jciarlo0/ERA5
ys=1999-1999

##############################
####### end of inputs ########
##############################
{
source /marconi/home/userexternal/ggiulian/STACK22/env2022
export SKIP_SAME_TIME=1

gdir=/marconi_scratch/userexternal/jciarlo0/GRIPHO
mdir=/marconi_scratch/userexternal/jciarlo0/islands

set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

if [ $# -lt 2 ]
then
   echo "Please provide Domain name and conf name in $rdir"
   echo "Example: $0 Africa NoTo"
   exit 1
fi
n=$1
path=$2-$1

wdir=$rdir/$path
odir=${wdir}/diurnal
mkdir -p $odir

v=pr
dom=${n}
dom1=${dom}-3km
[[ $dom = Mediterranean ]] && dom1=${dom}-03
[[ $path = ERA5-2km-CiSc ]] && dom1=${dom}-2km
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )

cp=true 
if [ $cp = true ]; then
  parentin=${path}.in
  pdir=$( cat $parentin | grep coarse_outdir | cut -d"'" -f2 )
  pdom=$( cat $parentin | grep coarse_domname | cut -d"'" -f2 )
fi

isles="Sicily"
seas="DJF JJA"
declare -a hours=( '00' '01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12' '13' '14' '15' '16' '17' '18' '19' '20' '21' '22' '23' )

#Check if hourly data for season is available
nf=$( eval ls $wdir/${dom1}_SRF.{${fyr}..${lyr}}??????.nc | wc -l )
if [ $nf -lt 1 ]; then
  echo "ERROR! files not found"
  echo "  dir = $wdir"
  echo "  dom = $dom"
  echo "  yrs = $ys"
  exit 1
fi

echo "## preparing merge file..."
mf=$odir/${v}_${dom}_${ys}.nc
if [ ! -f $mf ]; then
  for f in $( eval ls $wdir/${dom1}_SRF.{${fyr}..${lyr}}??????.nc ); do
    vf=$odir/${v}_$( basename $f )
    CDO -selvar,$v $f $vf
  done
  infs=$odir/${v}_${dom1}_SRF.{${fyr}..${lyr}}??????.nc
  eval CDO mergetime $infs $mf
  CDO mulc,3600 $mf ${mf}_tmp.nc
  mv ${mf}_tmp.nc $mf
  ncatted -a units,$v,m,c,"mm/hr" $mf
  eval rm $infs
fi

if [ $cp = true ]; then
  echo "## preparing parent merge file..."
  pf=$odir/${v}_${pdom}_${ys}.nc
  if [ ! -f $pf ]; then
    for f in $( eval ls $pdir/${pdom}_SHF.{${fyr}..${lyr}}??????.nc ); do
      vf=$odir/${v}_$( basename $f )
      CDO -selvar,$v $f $vf
    done
    infs=$odir/${v}_${pdom}_SHF.{${fyr}..${lyr}}??????.nc
    eval CDO mergetime $infs $pf
    CDO mulc,3600 $pf ${pf}_tmp.nc
    mv ${pf}_tmp.nc $pf
    ncatted -a units,$v,m,c,"mm/hr" $pf
    eval rm $infs
  fi
fi

## mask data & obs
for i in $isles; do 
  mapf=$mdir/islands-3_${i}_map.nc
  mskf=$odir/${i}_mask.nc

  mskfm=$odir/${i}_mask-model.nc
  mfi=$odir/${v}_${dom}_${i}_${ys}.nc

    mskfp=$odir/${i}_mask-parent.nc
    pfi=$odir/${v}_${pdom}_${i}_${ys}.nc

  echo "## masking OBS..."
  mskfo=$odir/${i}_mask-obs.nc
  obf=$gdir/pr_GRIPHO_1hr_2001-2016.nc
  obfi=$odir/pr_GRIPHO_${i}.nc
  CDO remapnn,$obf $mskf $mskfo
  CDO ifthen $mskfo $obf $obfi

  for s in $seas; do
    echo "## calculating for $s ..."
    sf=$odir/${v}_${dom}_${i}_${ys}_${s}.nc
    CDO selseas,$s $mfi $sf
    psf=$odir/${v}_${pdom}_${i}_${ys}_${s}.nc
    [[ $cp = true ]] && CDO selseas,$s $pfi $psf
    osf=$odir/pr_GRIPHO_${i}_${s}.nc
    CDO selseas,$s $obfi $osf

    for hh in ${hours[@]}; do
      hf=$odir/${v}_${dom}_${i}_${ys}_${s}_${hh}.nc
      CDO selhour,${hh} $sf $hf 
      phf=$odir/${v}_${pdom}_${i}_${ys}_${s}_${hh}.nc
      [[ $cp = true ]] && CDO  selhour,${hh} $psf $phf
      ohf=$odir/pr_GRIPHO_${i}_${s}_${hh}.nc
      CDO selhour,${hh} $osf $ohf

      hfm=$odir/${v}_${dom}_${i}_${ys}_${s}_${hh}_timmean.nc
      CDO timmean $hf $hfm
      phfm=$odir/${v}_${pdom}_${i}_${ys}_${s}_${hh}_timmean.nc
      [[ $cp = true ]] && CDO timmean $phf $phfm
      ohfm=$odir/pr_GRIPHO_${i}_${s}_${hh}_timmean.nc
      CDO timmean $ohf $ohfm

#     hfw=$odir/${v}_${dom}_${i}_${ys}_${s}_${hh}_WetFreq.nc
#     CDO  histfreq,0.1,10000 $hf $hfw
#     ohfw=$odir/pr_GRIPHO_${i}_${s}_${hh}_WetFreq.nc
#     CDO  histfreq,0.1,10000 $ohf $ohfw

#     hfp=$odir/${v}_${dom}_${i}_${ys}_${s}_${hh}_p99.nc
#     CDO timpctl,99 $hf -timmin $hf -timmax $hf $hfp
#     ohfp=$odir/pr_GRIPHO_${i}_${s}_${hh}_p99.nc
#     CDO timpctl,99 $ohf -timmin $ohf -timmax $ohf $ohfp

#     hfi=$odir/${v}_${dom}_${i}_${ys}_${s}_${hh}_INT.nc
#     CDO histmean,0.1,10000 $hf $hfi
#     ohfi=$odir/pr_GRIPHO_${i}_${s}_${hh}_INT.nc
#     CDO histmean,0.1,10000 $ohf $ohfi

#     hfpp=$odir/${v}_${dom}_${i}_${ys}_${s}_${hh}_p999.nc
#     CDO timpctl,99.9 $hf -timmin $hf -timmax $hf $hfpp
#     ohfpp=$odir/pr_GRIPHO_${i}_${s}_${hh}_p999.nc
#     CDO timpctl,99.9 $ohf -timmin $ohf -timmax $ohf $ohfpp

      rm $hf $ohf
      [[ $cp = true ]] && rm $phf
    done #hh

    hfms=$odir/${v}_${dom}_${i}_${ys}_${s}_??_timmean.nc
    hfdc=$odir/${v}_${dom}_${i}_${ys}_${s}_MeanDiurnalCycle.nc
    CDO fldmean -cat $hfms $hfdc
    phfms=$odir/${v}_${pdom}_${i}_${ys}_${s}_??_timmean.nc
    phfdc=$odir/${v}_${pdom}_${i}_${ys}_${s}_MeanDiurnalCycle.nc
    [[ $cp = true ]] && CDO fldmean -cat $phfms $phfdc
    ohfms=$odir/pr_GRIPHO_${i}_${s}_??_timmean.nc
    ohfdc=$odir/pr_GRIPHO_${i}_${s}_MeanDiurnalCycle.nc
    CDO fldmean -cat $ohfms $ohfdc
    rm $hfms $ohfms
    [[ $cp = true ]] && rm $phfms

#   hfws=$odir/${v}_${dom}_${i}_${ys}_${s}_??_WetFreq.nc
#   hfwdc=$odir/${v}_${dom}_${i}_${ys}_${s}_WetFreqDiurnalCycle.nc
#   CDO cat $hfws $hfwdc
#   ohfws=$odir/pr_GRIPHO_${i}_${s}_??_WetFreq.nc
#   ohfwdc=$odir/pr_GRIPHO_${i}_${s}_WetFreqDiurnalCycle.nc
#   CDO cat $ohfws $ohfwdc
#   rm $hfws $ohfws

#   hfps=$odir/${v}_${dom}_${i}_${ys}_${s}_??_p99.nc
#   hfpdc=$odir/${v}_${dom}_${i}_${ys}_${s}_p99DiurnalCycle.nc
#   CDO cat $hfps $hfpdc
#   ohfps=$odir/pr_GRIPHO_${i}_${s}_??_p99.nc
#   ohfpdc=$odir/pr_GRIPHO_${i}_${s}_p99DiurnalCycle.nc
#   CDO cat $ohfps $ohfpdc
#   rm $hfps $ohfps
 
#   hfis=$odir/${v}_${dom}_${i}_${ys}_${s}_??_INT.nc
#   hfidc=$odir/${v}_${dom}_${i}_${ys}_${s}_INTDiurnalCycle.nc
#   CDO cat $hfis $hfidc
#   ohfis=$odir/pr_GRIPHO_${i}_${s}_??_INT.nc
#   ohfidc=$odir/pr_GRIPHO_${i}_${s}_INTDiurnalCycle.nc
#   CDO cat $ohfis $ohfidc
#   rm $hfis $ohfis
 
#   hfpps=$odir/${v}_${dom}_${i}_${ys}_${s}_??_p999.nc
#   hfppdc=$odir/${v}_${dom}_${i}_${ys}_${s}_p999DiurnalCycle.nc
#   CDO cat $hfpps $hfppdc
#   ohfpps=$odir/pr_GRIPHO_${i}_${s}_??_p999.nc
#   ohfppdc=$odir/pr_GRIPHO_${i}_${s}_p999DiurnalCycle.nc
#   CDO cat $ohfpps $ohfppdc
#   rm $hfpps $ohfpps

  done #seas

done #isles

echo "Done"
}
