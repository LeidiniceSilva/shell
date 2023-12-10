#!/bin/bash
#SBATCH -N 1 
#SBATCH -t 4:00:00
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL
#SBATCH -p skl_usr_prod

source /marconi/home/userexternal/ggiulian/STACK22/env2022

#should be run after main postproc script
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

pdir=$hdir/plots
mkdir -p $pdir

seas="DJF MAM JJA SON"
vars="pr"
for s in $seas ; do
  echo "#### post-processing $n $s $ys ####"
  [[ $s = DJF ]] && mons="{12,01,02}"
  [[ $s = MAM ]] && mons="{03,04,05}"
  [[ $s = JJA ]] && mons="{06,07,08}"
  [[ $s = SON ]] && mons="{09,10,11}"

  for v in $vars; do
    if [ $n = Europe -o $n = Europe03 ]; then
      [[ $v = pr     ]] && o=("hires" "eobs" "mswep" "cpc" "gpcc") && res=("0.11" "0.1" "0.1" "0.1" "0.25")
    elif [ $n = WMediterranean ]; then
      [[ $v = pr     ]] && o=("hires" "eobs" "mswep") && res=("0.03" "0.1" "0.1")
    elif [ $n = EastAsia ]; then
      [[ $v = pr     ]] && o=("mswep" "cpc" "gpcc" "aphro" "cn05.1") && res=("0.1" "0.1" "0.25" "0.25" "0.25")
    else
      [[ $v = pr     ]] && o=("mswep" "cpc" "gpcc" 'cru') && res=("0.1" "0.1" "0.25" "0.5")
    fi
    echo "#=== $v ===#"
#   typ=STS

#   func="selvar,$v"
#   for f in $( eval ls $hdir/*${typ}.{${fyr}..${lyr}}${mons}*.nc ); do
#     of=$pdir/${n}_${v}_$( basename $f | cut -d'.' -f2 ).nc
#     CDO $func $f $of
#   done
#   sof=$pdir/${n}_${v}_${ys}_${s}.nc
#   CDO mergetime $( eval ls $pdir/${n}_${v}_{${fyr}..${lyr}}${mons}0100.nc ) $sof
#   rm $( eval ls $pdir/${n}_${v}_{${fyr}..${lyr}}${mons}0100.nc )

    mof=$pdir/${n}_${v}_${ys}_${s}_mean.nc
#   CDO timmean $sof $mof
#   rm $sof

#   cof=$pdir/${n}_${v}_${ys}_${s}_mean_tmp.nc
#   CDO mulc,86400 $mof $cof
#   ncatted -O -a units,pr,m,c,mm/day $cof
#   mv $cof $mof

    no=$(( ${#o[@]} - 1 ))
    echo $o, $no
    for i in `seq 0 $no`; do
      this_o=${o[i]}
      if [ $this_o = cpc -a $fyr -lt 1979 ]; then
        continue
      fi
      if [ $this_o = mswep -a $fyr -lt 1979 ]; then
        continue
      fi
      this_res=${res[i]}
      echo "#--- processing ${this_o^^} with resolution of ${this_res} ---#"
      obs="${v}_${this_o^^}_${ys}_${s}_mean.nc"
      if [ $this_o = "hires" ]; then
        hrdir=/marconi_work/ICT23_ESP/jciarlo0/obs/eur-hires
        [[ $n = Europe ]] && nn=EUR || nn=$n
        [[ $n = Europe03 ]] && nn=Europe 
        [[ $n = WMediterranean ]] && nn=Medi3 
        rrr=$( echo $this_res | cut -d. -f2 )
        obf=$( eval ls $hrdir/${v}_mean_${s}_EUR-HiRes_day_${nn}${rrr}grid.nc )
      else
        obf=$( eval ls $odir/$obs )
      fi
      ofr=$odir/$( basename $obf .nc )_${n}_${this_res}.nc
      mfr=$pdir/$( basename $mof .nc )_${n}_${this_res}.nc
      grid=$odir/${n}_${this_o^^}.grid
      ggiuldir=/marconi_work/ICT23_ESP/ggiulian/CORDEX-RegCM-Submit-main/scripts
#     python3 $ggiuldir/griddes_ll.py $mof $this_res > $grid
#     CDO remapnn,$grid $obf $ofr
#     CDO remapnn,$grid $mof $mfr
      bdif=$pdir/${n}_${v}_${ys}_${s}_bias_${this_o^^}.nc
      bof=$pdir/${n}_${v}pct_${ys}_${s}_bias_${this_o^^}.nc
      echo "Producing $bof"
      CDO mulc,100. -div $bdif $ofr $bof
#     CDO mulc,100. -div -setrtomiss,-0.5,0.5 $bdif $ofr $bof
#     CDO mulc,100. -div $bdif $ofr $bof
      ncatted -a units,$v,m,c,"%" $bof
    done
  done
done

echo "#### process complete! ####"
}
