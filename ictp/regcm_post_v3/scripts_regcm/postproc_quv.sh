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
scrdir=$6 

##############################
####### end of inputs ########
##############################

odir=/leonardo_work/ICT24_ESP/clu/CORDEX/obs
mdir=/leonardo_work/ICT24_ESP/clu/OBS/SREX
xdir=/marconi_work/ICT23_ESP/jciarlo0/CORDEX/ERA5/RegCM4/vertical
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
pdir=$hdir/quv
mkdir -p $pdir

dom=$n

# rotate ATM files (after sigma2p)
for f in $( eval ls $sdir/*ATM.{${fyr}..${lyr}}??*.nc | grep -v day_ | grep -v night_ ); do
	echo $f
	long_name=$( ncl_filedump $f | grep Wind )
	if [[ "$long_name" == *"Grid"* ]]; then
	  echo "Wind needs rotating!"
	  python3 $scrdir/rotatewinds.py $f
	else
	  echo "Wind already rotated ^_^"
	fi
done

vars="hus ua va"
seas="DJF MAM JJA SON"
for v in $vars; do
  r4log=F
  [[ $dom = CentralAmerica ]] && r4log=T
  [[ $dom = SouthAmerica   ]] && r4log=T
  [[ $dom = Europe         ]] && r4log=T
  [[ $dom = Africa         ]] && r4log=T
  [[ $dom = SouthEastAsia  ]] && r4log=T
  [[ $dom = Australasia    ]] && r4log=T
  r4log=F

  echo "#### quv-processing $path $ys $v ####"
  t=ATM
  [[ $v = hus ]] && vo=qhum && vi=q
  [[ $v = ua  ]] && vo=uwnd && vi=u
  [[ $v = va  ]] && vo=vwnd && vi=v

  for f in $( eval ls $sdir/*${t}.{${fyr}..${lyr}}??*.nc | grep -v day_ | grep -v night_ ); do
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

	# regrid
	res=0.25
	ofr=$pdir/${vo}_${obsn}_${ys}_${s}_mean_${res}.nc
    mfxr=$pdir/${v}_RegCM4_${ys}_${s}_mean_${res}.nc
    mfr=$pdir/${v}_RegCM5_${ys}_${s}_mean_${res}.nc
	grid=$pdir/${dom}_${obsn}.grid
    ggiuldir=/marconi_work/ICT23_ESP/ggiulian/CORDEX-RegCM-Submit-main/scripts
    python3 $ggiuldir/griddes_ll.py $mf $res > $grid
    CDO remapdis,$grid $ob1 $ofr
    [[ $r4log = T ]] && CDO remapdis $grid $mfx $mfxr
    CDO remapdis,$grid $mf $mfr
	
    #rm $pdir/${vo}_${obsn}_${ys}_${s}_mean.nc
    #[[ $r4log = T ]] && rm $pdir/${v}_RegCM4_${ys}_${s}_mean.nc
    #rm $pdir/${v}_RegCM5_${ys}_${s}_mean.nc
    rm $pdir/${v}_RegCM5_${ys}_${s}.nc
  done
  eval rm $pdir/${v}_{${fyr}..${lyr}}??0100.nc 
done

echo "#### process complete! ####"

}
