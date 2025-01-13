#!/bin/bash
#SBATCH -N 1 
#SBATCH -t 8:00:00
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL
#SBATCH -p skl_usr_prod  

source /marconi/home/userexternal/ggiulian/STACK22/env2022

##############################
### change inputs manually ###
##############################

n=$1
path=$2-$1
rdir=$3 #/marconi_scratch/userexternal/jciarlo0/ERA5
ys=$5 #2000-2001

##############################
### change inputs manually ###
##############################

odir=/marconi_work/ICT23_ESP/ggiulian/OBS/ERA5
xdir=/marconi_work/ICT23_ESP/jciarlo0/CORDEX/ERA5/RegCM4/vertical
mdir=/marconi_work/ICT23_ESP/ggiulian/OBS/SREX
obsn=ERA5

export REMAP_EXTRAPOLATE=off

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
[[ $dom = NorthAmerica   ]] && subregs="NWN NEN GIC WNA CNA ENA NCA"
[[ $dom = CentralAmerica ]] && subregs="NCA SCA CAR"
[[ $dom = SouthAmerica   ]] && subregs="NWS NSA SAM NES SES SWS SSA"
[[ $dom = Africa         ]] && subregs="SAH WAF CAF NEAF SEAF ARP WSAF ESAF MDG"
[[ $dom = SouthAsia      ]] && subregs="WCA ECA TIB SAS ARP"
[[ $dom = EastAsia       ]] && subregs="ESB RFE ECA TIB EAS"
[[ $dom = SouthEastAsia  ]] && subregs="SEA"
[[ $dom = Australasia    ]] && subregs="NAU CAU EAU SAU NZ"

[[ $dom = CentralAmerica ]] && ddd=CAM
[[ $dom = SouthAmerica   ]] && ddd=SAM
[[ $dom = Europe         ]] && ddd=EUR
[[ $dom = Africa         ]] && ddd=AFR
[[ $dom = SouthEastAsia  ]] && ddd=SEA
[[ $dom = Australasia    ]] && ddd=AUS

vars="clw cli cl"
seas="DJF MAM JJA SON"

rsdt=RAD
for file in $(eval ls $hdir/*${rsdt}.{${fyr}..${lyr}}??*.nc); do
        rad_file=$( basename $file | rev |cut -d'/' -f1 | rev )
        cdo selvar,rsdt $file $sdir/rsdt_$rad_file
        cdo eqc,0 $sdir/rsdt_$rad_file $sdir/night_$rad_file
        cdo setctomiss,0 $sdir/night_$rad_file $sdir/night2_$rad_file
        mv $sdir/night2_$rad_file $sdir/night_$rad_file

        cdo gtc,0 $sdir/rsdt_$rad_file $sdir/day_$rad_file
        cdo setctomiss,0 $sdir/day_$rad_file $sdir/day2_$rad_file
        mv $sdir/day2_$rad_file $sdir/day_$rad_file
	rm $sdir/rsdt_$rad_file 
done
for v in $vars; do
  r4log=F
  [[ $dom = CentralAmerica ]] && r4log=T
  [[ $dom = SouthAmerica   ]] && r4log=T
  [[ $dom = Europe         ]] && r4log=T
  [[ $dom = Africa         ]] && r4log=T
  [[ $dom = SouthEastAsia  ]] && r4log=T
  [[ $dom = Australasia    ]] && r4log=T
  [[ $v = cli ]] && r4log=F

  echo "#### vert-processing $path $ys $v ####"
  t=ATM
 #[[ $v = cl ]] && sdir=$hdir/cosp
  [[ $v = cl ]] && t=RAD
 #[[ $v = cl ]] && vn=clcalipso
  [[ $v = clw ]] && vo=clliq
  [[ $v = cli ]] && vo=clice
  [[ $v = cl  ]] && vo=clfrac
  [[ $v = clw ]] && vi=clwc
  [[ $v = cli ]] && vi=ciwc
  [[ $v = cl  ]] && vi=cc
  
  rsdt=RAD
  for file in $(eval ls $hdir/*${rsdt}.{${fyr}..${lyr}}??*.nc); do
        rad_file=$( basename $file | rev |cut -d'/' -f1 | rev )
        end=$( basename $rad_file | cut -d'.' -f2 | cut -c1-10 )
        begin=$( basename $rad_file | cut -d'_' -f1 )
        cdo div $sdir/$begin"_"$t"."$end"_pressure.nc" $sdir/day_$rad_file $sdir/"day_"$begin"_"$t"."$end"_pressure.nc"
        cdo div $sdir/$begin"_"$t"."$end"_pressure.nc" $sdir/night_$rad_file $sdir/"night_"$begin"_"$t"."$end"_pressure.nc"
        
        of_day=$pdir/${v}"_day_"$( basename $rad_file | cut -d'.' -f2 | cut -c1-10 ).nc
        of_night=$pdir/${v}"_night_"$( basename $rad_file | cut -d'.' -f2 | cut -c1-10 ).nc
        cdo selvar,$v $sdir/"day_"$begin"_"$t"."$end"_pressure.nc" $of_day
        cdo selvar,$v $sdir/"night_"$begin"_"$t"."$end"_pressure.nc" $of_night 
        rm $sdir/"day_"$begin"_"$t"."$end"_pressure.nc" $sdir/"night_"$begin"_"$t"."$end"_pressure.nc"
  done
  time_of_day="day night"
  for switch in $time_of_day; do
  for s in $seas; do
    echo "#### ... $s ... ####"  
    [[ $s = DJF ]] && mons="{12,01,02}"
    [[ $s = MAM ]] && mons="{03,04,05}"
    [[ $s = JJA ]] && mons="{06,07,08}"
    [[ $s = SON ]] && mons="{09,10,11}"
    ## RegCM5 season proc
    cf=$pdir/${v}_${switch}_RegCM5_${ys}_${s}.nc
    echo $cf
    echo ${pdir}/${v}_${switch}_{${fyr}..${lyr}}${mons}*.nc
    files=$( eval ls ${pdir}/${v}_${switch}_{${fyr}..${lyr}}${mons}*.nc )
    CDO mergetime $files $cf
    mf=$pdir/${v}_${switch}_RegCM5_${ys}_${s}_mean.nc
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
      mskf5=$pdir/${sr}-RegCM5_mask.nc
      CDO griddes $mskf > $mski
      sed -i "s/generic/lonlat/g" $mski
      CDO setgrid,$mski $mskf $mskf2
      CDO remapnn,$mf $mskf2 $mskf5
      rm $mski $mskf2

      sf5=$pdir/${v}_${switch}_RegCM5_${sr}_${ys}_${s}_mean.nc
      CDO ifthen $mskf5 $mf $sf5
      rm $mskfo $mskf5

      vf5=$pdir/${v}_${switch}_RegCM5_${sr}_${ys}_${s}_profile.nc
      CDO fldmean $sf5 $vf5
    done
    rm $pdir/${v}_${switch}_RegCM5_${ys}_${s}.nc $pdir/${v}_${switch}_RegCM5_${ys}_${s}_mean.nc
  done
  eval rm $pdir/${v}_${switch}_{${fyr}..${lyr}}??0100.nc 
 done 
done

echo "#### process complete! ####"

}
