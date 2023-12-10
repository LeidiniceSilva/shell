#!/bin/bash
#SBATCH -N 1 
#SBATCH -t 8:00:00
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=jciarlo@ictp.it
#SBATCH -p skl_usr_prod

source /marconi/home/userexternal/ggiulian/STACK22/env2022

##############################
### change inputs manually ###
##############################

n=$1
path=$2-$1
rdir=$3 #/marconi_scratch/userexternal/jciarlo0/ERA5
odir=$4 #/marconi_scratch/userexternal/jciarlo0/ERA5/obs
ys=$5 #1999-1999

##############################
####### end of inputs ########
##############################

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

hdir=$rdir/$path
if [ ! -d $hdir ]
then
  echo 'Path does not exist: '$hdir
  exit -1
fi

ff=$hdir/*.nc
if [ -z "$ff" ]
then
  echo 'No files: '$ff
  exit -1
fi

dom=$n
conf=$2
[[ $dom = Europe ]] && gdom=EUR-11
[[ $dom = WMediterranean ]] && gdom=WMD-03
if [ $gdom = WMD-03 ]; then
  echo "cp simulation does not have prc"
  exit 1
fi
[[ $conf = ERA5 ]] && gcon=ECMWF-ERA5
[[ $conf = MPI ]] && gcon=DKRZ-MPI-ESM1-2-HR
[[ $conf = NorESM ]] && gcon=NCC-NorESM2-MM
[[ $conf = EcEarth ]] && gcon=EC-Earth-Consortium-EC-Earth3-Veg
gdir=/marconi_scratch/userexternal/jciarlo0/gsstmp/

pdir=$hdir/plots
mkdir -p $pdir

seas="DJF MAM JJA SON"
vars="pr prc"
#vars=snw
for s in $seas ; do
  echo "#### post-processing $n $s $ys ####"
  [[ $s = DJF ]] && mons="{12,01,02}"
  [[ $s = MAM ]] && mons="{03,04,05}"
  [[ $s = JJA ]] && mons="{06,07,08}"
  [[ $s = SON ]] && mons="{09,10,11}"

  for v in $vars; do
    echo "#=== $v ===#"
    typ=SRF

    # find data
    set +e
    files="$hdir/*${typ}.{${fyr}..${lyr}}${mons}*.nc"
    firstf=$( eval ls $files 2>/dev/null | head -1 ) && iwrk=true || iwrk=false
    gprt="${v}_${gdom}_${gcon}_*_day_"
    gfiles="$gdir/${gprt}{${fyr}..${lyr}}${mons}*.nc"
    [[ $iwrk = false ]] && firstf=$( eval ls $gfiles 2>/dev/null | head -1 )
    [[ -f $firstf ]] && ifdat=true || ifdat=false
    set -e
    if [ $ifdat = false ]; then
      echo "ERROR. Data not found in either directories."
      echo "  hdir=$files"
      echo "  gdir=$gfiles"
      exit 1
    fi

    sof=$pdir/${n}_${v}_${ys}_${s}.nc
    if [ $iwrk = true ]; then
      func="selvar,$v"
      for f in $( eval ls $files ); do
        of=$pdir/${n}_${v}_$( basename $f | cut -d'.' -f2 ).nc
        CDO $func $f $of
      done
      sof=$pdir/${n}_${v}_${ys}_${s}.nc
      CDO mergetime $( eval ls $pdir/${n}_${v}_{${fyr}..${lyr}}${mons}*.nc ) $sof
      rm $( eval ls $pdir/${n}_${v}_{${fyr}..${lyr}}${mons}*.nc )
    else
      CDO mergetime $( eval ls $gfiles ) $sof
    fi

    mof=$pdir/${n}_${v}_${ys}_${s}_mean.nc
    CDO timmean $sof $mof
    rm $sof

    cof=$pdir/${n}_${v}_${ys}_${s}_mean_tmp.nc
    CDO mulc,86400 $mof $cof
    ncatted -O -a units,$v,m,c,mm/day $cof
    mv $cof $mof
  done

  echo " calculating ratio..."
  prcf=$pdir/${n}_prc_${ys}_${s}_mean.nc
  prtf=$pdir/${n}_pr_${ys}_${s}_mean.nc
  ratf=$pdir/${n}_prc2pr_${ys}_${s}_mean.nc
  CDO div $prcf $prtf $ratf
done

echo "#### process complete! ####"
}
