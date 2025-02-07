#!/bin/bash

#SBATCH -A ICT23_ESP_1
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1 
#SBATCH -t 4:00:00
#SBATCH --ntasks-per-node=108
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it

source /leonardo/home/userexternal/ggiulian/modules_gfortran

##############################
### change inputs manually ###
##############################

n=$1
path=$2-$1
rdir=$3 
ys=$5 

##############################
### change inputs manually ###
##############################

odir=/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/obs
mdir=/leonardo/home/userexternal/mdasilva/leonardo_work/SREX
xdir=/marconi_work/ICT23_ESP/jciarlo0/CORDEX/ERA5/RegCM4/vertical
obsn=ERA5

export REMAP_EXTRAPOLATE=off
export SKIP_SAME_TIME=1

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

#if [ $# -ne 2 ]
#then
#   echo "Please provide Domain name and conf name in $rdir"
#   echo "Example: $0 Africa NoTo"
#   exit 1
#fi

fyr=$( echo $ys | cut -d- -f1 )
lyr=$( echo $ys | cut -d- -f2 )
aobs="on"
if [ $obsn = ERA5 -a $fyr -lt 1979 ]; then
  echo "## Working with $obsn for $ys ##"
  echo "##   $obsn starts from 1979   ##"
  echo "##   using 1980-1989          ##"
  aobs="off"
fi

hdir=$rdir/$path
if [ ! -d $hdir ]; then
  echo 'Path does not exist: '$hdir
  exit -1
fi

ff=$hdir/*.nc
if [ -z "$ff" ]; then
  echo 'No files: '$ff
  exit -1
fi

sdir=$hdir/pressure
pdir=$hdir/vert
tdir=$hdir/pdfs
mkdir -p $pdir

dom=$n
subregs="FullDom"
[[ $dom = Europe         ]] && subregs="MED NEU WCE"
[[ $dom = Europe03       ]] && subregs="MED NEU WCE"
[[ $dom = NorthAmerica   ]] && subregs="NWN NEN WNA CNA ENA NCA"
[[ $dom = CentralAmerica ]] && subregs="NCA SCA CAR"
[[ $dom = SouthAmerica   ]] && subregs="NWS NSA SAM NES SES SWS SSA"
[[ $dom = Africa         ]] && subregs="SAH WAF CAF NEAF SEAF ARP WSAF ESAF MDG"
[[ $dom = SouthAsia      ]] && subregs="WCA ECA TIB SAS ARP"
[[ $dom = EastAsia       ]] && subregs="ESB RFE ECA TIB EAS"
[[ $dom = SouthEastAsia  ]] && subregs="SEA"
[[ $dom = Australasia    ]] && subregs="NAU CAU EAU SAU NZ"

[[ $dom = Mediterranean  ]] && subregs="CARPAT EURO4M RdisaggH GRIPHO COMEPHORE"  #SPAIN02
[[ $dom = WMediterranean ]] && subregs="CARPAT EURO4M RdisaggH GRIPHO COMEPHORE"  #SPAIN02
[[ $dom = SEEurope       ]] && subregs="GRIPHO COMEPHORE"
if [ $dom = WMediterranean ]; then
  hrdir=/marconi_work/ICT23_ESP/jciarlo0/obs/eur-hires/
  mdir=$hrdir
fi

[[ $dom = CentralAmerica ]] && ddd=CAM
[[ $dom = SouthAmerica   ]] && ddd=SAM
[[ $dom = Europe         ]] && ddd=EUR
[[ $dom = Africa         ]] && ddd=AFR
[[ $dom = SouthEastAsia  ]] && ddd=SEA
[[ $dom = Australasia    ]] && ddd=AUS

vars="clw cli cl hus rh"
seas="DJF MAM JJA SON"
for v in $vars; do
  r4log=F
  [[ $dom = CentralAmerica ]] && r4log=F
  [[ $dom = SouthAmerica   ]] && r4log=F
  [[ $dom = Europe         ]] && r4log=F
  [[ $dom = Africa         ]] && r4log=F
  [[ $dom = SouthEastAsia  ]] && r4log=F
  [[ $dom = Australasia    ]] && r4log=F
  [[ $v = cli ]] && r4log=F
# [[ $path = MPI-Europe ]] && r4log=F
# [[ $path = ERA5-Europe ]] && r4log=F

  echo "#### vert-processing $path $ys $v ####"
  t=ATM
  [[ $v = cl ]] && t=RAD
  [[ $v = clw ]] && vo=clliq
  [[ $v = cli ]] && vo=clice
  [[ $v = cl  ]] && vo=clfrac
  [[ $v = hus ]] && vo=qhum
  [[ $v = rh  ]] && vo=rhum
  [[ $v = clw ]] && vi=clwc
  [[ $v = cli ]] && vi=ciwc
  [[ $v = cl  ]] && vi=cc
  [[ $v = hus ]] && vi=q
  [[ $v = rh  ]] && vi=r
  
  for f in $( eval ls $sdir/*${t}.{${fyr}..${lyr}}??*.nc | grep -v day | grep -v night ); do
    echo $f ..
    of=$pdir/${v}_$( basename $f | cut -d'.' -f2 | cut -c1-10 ).nc
    CDO selvar,$v $f $of
  done

  for s in $seas; do
    echo "#### ... $s ... ####"  
    [[ $s = DJF ]] && mons="{12,01,02}"
    [[ $s = MAM ]] && mons="{03,04,05}"
    [[ $s = JJA ]] && mons="{06,07,08}"
    [[ $s = SON ]] && mons="{09,10,11}"

    ## OBS season proc
    ob0=$odir/${vo}_${obsn}_${ys}.nc
    ob1=$pdir/${vo}_${obsn}_${ys}_${s}_mean.nc
    [[ $aobs = off ]] && ob0=$odir/${vo}_${obsn}_1980-1989.nc
    CDO timmean -chname,$vi,$v -selseas,$s $ob0 $ob1

    ## RegCM4 season proc
    cfx=$xdir/${v}_${ddd}_RegCM4_${ys}.nc
    mfx=$pdir/${v}_RegCM4_${ys}_${s}_mean.nc
    [[ $r4log = T ]] && CDO timmean -selseas,$s $cfx $mfx

    ## RegCM5 season proc
    cf=$pdir/${v}_RegCM5_${ys}_${s}.nc
    files=$( eval ls $pdir/${v}_{${fyr}..${lyr}}${mons}*.nc )
    CDO mergetime $files $cf
    mf=$pdir/${v}_RegCM5_${ys}_${s}_mean.nc
    CDO timmean $cf $mf

    for sr in $subregs; do
      echo "#### ### ... $sr ... ### ####"
      if [ $sr = FullDom ]; then
        mskf=$tdir/${sr}_mask0.nc
      else
        mskf=$mdir/${sr}_mask.nc
      fi
      mski=$pdir/${sr}.info
      mskf2=$pdir/${sr}_mask.nc
      mskfo=$pdir/${sr}-${obsn}_mask.nc
      mskfc=$pdir/${sr}-${obsn}_common.nc
      mskf4=$pdir/${sr}-RegCM4_mask.nc
      mskf5=$pdir/${sr}-RegCM5_mask.nc

      [[ $sr = SPAIN02 ]] && sg="-selgrid,2" || sg=""
      if [ $sr = SPAIN02 ]; then
        CDO remapnn,$ob1 $sg $mskf $mskfo
      else
        CDO griddes $mskf > $mski
        sed -i "s/generic/lonlat/g" $mski
        CDO setgrid,$mski $mskf $mskf2
        CDO remapnn,$ob1 $mskf2 $mskfo
        rm $mski $mskf2
      fi
      ## setting common area: for masks that spill over edge of domain
      CDO remapnn,$mf $mskfo $mskfc
      CDO remapnn,$mskfo $mskfc ${mskfc}2.nc
      mv ${mskfc}2.nc $mskfc
      ## end common area
      [[ $r4log = T ]] && CDO remapnn,$mfx $mskfc $mskf4
      CDO remapnn,$mf $mskfc $mskf5

      sfo=$pdir/${v}_${obsn}_${sr}_${ys}_${s}_mean.nc
      sf4=$pdir/${v}_RegCM4_${sr}_${ys}_${s}_mean.nc
      sf5=$pdir/${v}_RegCM5_${sr}_${ys}_${s}_mean.nc
      CDO ifthen $mskfo $ob1 $sfo
      [[ $r4log = T ]] && CDO ifthen $mskf4 $mfx $sf4
      CDO ifthen $mskf5 $mf $sf5
      rm $mskfo $mskf5

      vfo=$pdir/${v}_${obsn}_${sr}_${ys}_${s}_profile.nc
      vf4=$pdir/${v}_RegCM4_${sr}_${ys}_${s}_profile.nc
      vf5=$pdir/${v}_RegCM5_${sr}_${ys}_${s}_profile.nc
      CDO fldmean $sfo $vfo
      [[ $r4log = T ]] && CDO fldmean $sf4 $vf4
      CDO fldmean $sf5 $vf5
    done
    rm $pdir/${vo}_${obsn}_${ys}_${s}_mean.nc
    [[ $r4log = T ]] && rm $pdir/${v}_RegCM4_${ys}_${s}_mean.nc
    rm $pdir/${v}_RegCM5_${ys}_${s}.nc $pdir/${v}_RegCM5_${ys}_${s}_mean.nc
  done
  eval rm $pdir/${v}_{${fyr}..${lyr}}??????.nc 
done

echo "#### process complete! ####"

}
