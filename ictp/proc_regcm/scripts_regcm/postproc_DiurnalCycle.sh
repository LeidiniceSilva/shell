#!/bin/bash
#SBATCH --account=ICT23_ESP
#SBATCH -N 1  
#SBATCH -t 24:00:00
#SBATCH -p skl_usr_prod  
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH --qos=qos_prio

##############################
### change inputs manually ###
##############################

n=$1
path=$2-$1
rdir=$3 
#odir=$4 
ys=$5 
conf=$2

##############################
####### end of inputs ########
##############################

{
source /marconi/home/userexternal/ggiulian/STACK22/env2022
export SKIP_SAME_TIME=1

gdir=/marconi_work/ICT23_ESP/jciarlo0/obs/eur-hires
mdir=/marconi_scratch/userexternal/jciarlo0/islands

set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

#if [ $# -lt 2 ]
#then
#   echo "Please provide Domain name and conf name in $rdir"
#   echo "Example: $0 Africa NoTo"
#   exit 1
#fi

wdir=$rdir/$path
odir=${wdir}/diurnal
mkdir -p $odir

v=pr
dom=${n}
#dom1=${dom}-3km
[[ $dom = WMediterranean ]] && dom1=WMD-03
[[ $dom = Europe03 ]] && dom1=WP3_yellowS
fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
[[ $dom = Europe ]] && gdom=EUR-11
[[ $dom = WMediterranean ]] && gdom=WMD-03
[[ $conf = ERA5 ]] && gcon=ECMWF-ERA5
[[ $conf = MPI ]] && gcon=DKRZ-MPI-ESM1-2-HR
[[ $conf = NorESM ]] && gcon=NCC-NorESM2-MM
[[ $conf = EcEarth ]] && gcon=EC-Earth-Consortium-EC-Earth3-Veg
gsdir=/marconi_scratch/userexternal/jciarlo0/gsstmp/

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
[[ $cp = true ]] && typ=SRF || typ=SHF
[[ $gdom = WMD-03 ]] && gsdir=$wdir/CORDEX/output/$gdom/ICTP/$gcon/*/r*/ICTP-RegCM5-0/v*/1hr/$v/
set +e
wfiles="$wdir/${dom1}_${typ}.{${fyr}..${lyr}}??????.nc"
gfiles="$gsdir/${v}_*_{${fyr}..${lyr}}*.nc"
firstf=$( eval ls $wfiles 2>/dev/null | head -1 ) && inwork=true || inwork=false
[[ $inwork = false ]] && firstf=$( eval ls $gfiles 2>/dev/null | head -1 )
[[ -f $firstf ]] && ifdat=true || ifdat=false
set -e
if [ $ifdat = false ]; then
  echo "ERROR. Data not found in either directories."
  echo "  ddir=$wfiles"
  echo "  gdir=$gfiles"
  exit 1
fi

echo "## preparing merge file..."
mf=$odir/${v}_${dom}_${ys}.nc
if [ ! -f $mf ]; then
  if [ $inwork = true ]; then
    for f in $( eval ls $wfiles ); do
      vf=$odir/${v}_$( basename $f )
      CDO -selvar,$v $f $vf
    done
    infs=$odir/${v}_${dom1}_${typ}.{${fyr}..${lyr}}??????.nc
    eval CDO mergetime $infs $mf
    CDO mulc,3600 $mf ${mf}_tmp.nc
    mv ${mf}_tmp.nc $mf
    ncatted -a units,$v,m,c,"mm/hr" $mf
    eval rm $infs
  else
    CDO mulc,3600 -mergetime $( eval ls $gfiles ) $mf
    ncatted -a units,$v,m,c,"mm/hr" $mf
  fi
fi

if [ $cp = true ]; then
  #Check if hourly data for season is available
  typ=SHF
  gsdir=/marconi_scratch/userexternal/jciarlo0/gsstmp/
  set +e
  pwfiles="$pdir/${pdom}_${typ}.{${fyr}..${lyr}}??????.nc"
  pgfiles="$gsdir/${v}_*_{${fyr}..${lyr}}*.nc"
  firstf=$( eval ls $pwfiles 2>/dev/null | head -1 ) && inwork=true || inwork=false
  [[ $inwork = false ]] && firstf=$( eval ls $pgfiles 2>/dev/null | head -1 )
  [[ -f $firstf ]] && ifdat=true || ifdat=false
  set -e
  if [ $ifdat = false ]; then
    echo "ERROR. Parent Data not found in either directories."
    echo "  ddir=$pwfiles"
    echo "  gdir=$pgfiles"
    exit 1
  fi

  echo "## preparing parent merge file..."
  pf=$odir/${v}_${pdom}_${ys}.nc
  if [ ! -f $pf ]; then
    if [ $inwork = true ]; then
      for f in $( eval ls $pwfiles ); do
        vf=$odir/${v}_$( basename $f )
        CDO -selvar,$v $f $vf
      done
      infs=$odir/${v}_${pdom}_${typ}.{${fyr}..${lyr}}??????.nc
      eval CDO mergetime $infs $pf
      CDO mulc,3600 $pf ${pf}_tmp.nc
      mv ${pf}_tmp.nc $pf
      ncatted -a units,$v,m,c,"mm/hr" $pf
      eval rm $infs
    else
      CDO mulc,3600 -mergetime $( eval ls $pgfiles ) $pf
      ncatted -a units,$v,m,c,"mm/hr" $pf
    fi
  fi
fi

## mask data & obs
for i in $isles; do 
  echo "## preparing $i mask ..."
  mapf=$mdir/islands-3_${i}_map.nc
  mskf=$odir/${i}_mask.nc
  [[ ! -f $mskf ]] && CDO gtc,0. $mapf $mskf

# ## extracting sicily lat lon
# echo "## extracting sicily lat lon data.."
# l=0
# stn_list=/marconi_work/ICT23_ESP/jciarlo0/obs/eur-hires/GRIPHO-sicily.latlon
# mfens=$odir/${v}_${dom}_${ys}_sicily-stn-ensmean.nc
# pfens=$odir/${v}_${pdom}_${ys}_sicily-stn-ensmean.nc
# for ll in $( cat $stn_list ); do
#   lat=$( echo $ll | cut -d, -f1 )
#   lon=$( echo $ll | cut -d, -f2 )
#   l=$(( l+1 ))
#   [[ $l = 8 ]] && continue #skipping due to unsolved unknown error
#   [[ $l = 90 ]] && continue
#   echo ".... $l/312 ...."
#   if [ ! -f $mfens ]; then
#     mfll=$odir/${v}_${dom}_${ys}_ll${l}.nc
#     [[ ! -f $mfll ]] && CDO remapnn,lon=${lon}_lat=$lat $mf $mfll
#   fi
#   if [ $cp = true -a ! -f $pfens ]; then
#     pfll=$odir/${v}_${pdom}_${ys}_ll${l}.nc
#     [[ ! -f $pfll ]] && CDO remapnn,lon=${lon}_lat=$lat $pf $pfll
#   fi
# done
# mflls="$odir/${v}_${dom}_${ys}_ll*.nc"
# if [ ! -f $mfens ]; then
#   eval CDO ensmean $mflls $mfens
#   rm $mflls
# fi
# if [ $cp = true ]; then
#   pflls="$odir/${v}_${pdom}_${ys}_ll*.nc"
#   if [ ! -f $pfens ]; then
#     eval CDO ensmean $pflls $pfens
#     rm $pflls
#   fi
# fi

  echo "## masking RCM to $i ..."
  mskfm=$odir/${i}_mask-model.nc
  mfi=$odir/${v}_${dom}_${i}_${ys}.nc
  if [ ! -f $mfi ]; then
    CDO remapnn,$mf $mskf $mskfm
    CDO ifthen $mskfm $mf $mfi
  fi

  if [ $cp = true ]; then  
    echo "## masking parent RCM to $i ..."
    mskfp=$odir/${i}_mask-parent.nc
    pfi=$odir/${v}_${pdom}_${i}_${ys}.nc
    if [ ! -f $pfi ]; then
      CDO remapnn,$pf $mskf $mskfp
      CDO ifthen $mskfp $pf $pfi
    fi
  fi

  echo "## masking OBS..."
  mskfo=$odir/${i}_mask-obs.nc
  [[ $lyr -le 2005 ]] && otim=2001-2005 || otim=2001-2016
  obf=$gdir/pr_GRIPHO_1hr_${otim}.nc
  obfi=$odir/pr_GRIPHO_${i}.nc
  if [ ! -f $obfi ]; then
    CDO remapnn,$obf $mskf $mskfo
    CDO ifthen $mskfo $obf $obfi
  fi

  for s in $seas; do
    echo "## calculating for $s ..."
    sf=$odir/${v}_${dom}_${i}_${ys}_${s}.nc
    CDO selseas,$s $mfi $sf
#   CDO selseas,$s $mfens $sf
    psf=$odir/${v}_${pdom}_${i}_${ys}_${s}.nc
    [[ $cp = true ]] && CDO selseas,$s $pfi $psf
#   [[ $cp = true ]] && CDO selseas,$s $pfens $psf
    osf=$odir/pr_GRIPHO_${i}_${s}.nc
#   obf=$gdir/pr_GRIPHO-stn-sicily-avg_2001-2016.nc
    CDO selseas,$s $obfi $osf
#   CDO selseas,$s -chname,pr2,pr -selvar,pr2 $obf $osf

    for hh in ${hours[@]}; do
      echo "## ## $s hour $hh / 24 ... ..."
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

    echo "## finalizing $s ..."
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
