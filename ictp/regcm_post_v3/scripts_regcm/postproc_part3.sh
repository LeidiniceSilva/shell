#!/bin/bash

#SBATCH -N 1 
#SBATCH -t 4:00:00
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL
#SBATCH -p skl_usr_prod

source /marconi/home/userexternal/ggiulian/STACK22/env2022

##############################
### change inputs manually ###
##############################

n=$1
path=$2-$1
rdir=$3 
odir=$4 
ys=$5 
export scrdir=$6 

##############################
####### end of inputs ########
##############################

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

#hdir=$rdir/$path
export hdir=$rdir/$path
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
vars="rsnl"
#seas="DJF"
#seas="MAM JJA SON"
#vars="pr tas tasmax tasmin clt"
#vars="pr"
#if [ $n = Europe -o $n = NorthAmerica -o $n = EastAsia ]; then
#  vars="$vars snw"
#fi
for s in $seas ; do
  echo "#### post-processing $n $s $ys ####"
  [[ $s = DJF ]] && mons="{12,01,02}"
  [[ $s = MAM ]] && mons="{03,04,05}"
  [[ $s = JJA ]] && mons="{06,07,08}"
  [[ $s = SON ]] && mons="{09,10,11}"

  for v in $vars; do
#    if [ $n = Europe -o $n = Europe03 ]; then
#      [[ $v = pr     ]] && o=("hires" "eobs" "mswep" "cpc" "gpcc") && res=("0.11" "0.1" "0.1" "0.1" "0.25")
#      [[ $v = tas    ]] && o=("eobs") && res=("0.1")
#    elif [ $n = Mediterranean -o $n = SEEurope -o $n = WMediterranean ]; then
#      [[ $v = pr     ]] && o=("hires" "eobs" "mswep") && res=("0.03" "0.1" "0.1")
#      [[ $v = tas    ]] && o=("eobs") && res=("0.1")
#    elif [ $n = EastAsia ]; then
#      [[ $v = pr     ]] && o=("mswep" "cpc" "gpcc" "aphro" "cn05.1") && res=("0.1" "0.1" "0.25" "0.25" "0.25")
#      [[ $v = tas    ]] && o=("cru" "cn05.1") && res=("0.5" "0.25")
#    else
#      [[ $v = pr     ]] && o=("mswep" "cpc" "gpcc" 'cru') && res=("0.1" "0.1" "0.25" "0.5")
#      [[ $v = tas    ]] && o=("cru") && res=("0.5")
#    fi
#    [[ $v = tasmax ]] && o=("cru") && res=("0.5")
#    [[ $v = tasmin ]] && o=("cru") && res=("0.5")
#    [[ $v = clt    ]] && o=("cru") && res=("0.5")
#    [[ $v = snw    ]] && o=("swe") && res=("1.0")
	o=("era5")
	res=("0.25")
    echo "#=== $v ===#"
    typ=STS
    [[ $v = clt ]] && typ=SRF
    [[ $v = snw ]] && typ=SRF
    [[ $v = rsnl ]] && typ=RAD

    func="selvar,$v"
    [[ $v = clt ]] && func="daymean -selvar,$v"
    [[ $v = snw ]] && func="daymean -selvar,$v"
    [[ $v = rsnl ]] && func="daymean -selvar,$v"
    for f in $( eval ls $hdir/*${typ}.{${fyr}..${lyr}}${mons}*.nc ); do
      of=$pdir/${n}_${v}_$( basename $f | cut -d'.' -f2 ).nc
      CDO $func $f $of
    done
    sof=$pdir/${n}_${v}_${ys}_${s}.nc
    CDO mergetime $( eval ls $pdir/${n}_${v}_{${fyr}..${lyr}}${mons}*.nc ) $sof
    rm $( eval ls $pdir/${n}_${v}_{${fyr}..${lyr}}${mons}*.nc )

    mof=$pdir/${n}_${v}_${ys}_${s}_mean.nc
    CDO timmean $sof $mof
    rm $sof

#    if [ $v = pr ]; then
#      cof=$pdir/${n}_${v}_${ys}_${s}_mean_tmp.nc
#      CDO mulc,86400 $mof $cof
#      ncatted -O -a units,pr,m,c,mm/day $cof
#      mv $cof $mof
#    elif [ $v = tas -o $v = tasmax -o $v = tasmin ]; then
#      cof=$pdir/${n}_${v}_${ys}_${s}_mean_tmp.nc
#      CDO subc,273.15 $mof $cof
#      ncatted -O -a units,$v,m,c,Celsius $cof
#      mv $cof $mof
#    fi

#	# apply land-sea mask
#	#export mf=$( eval ls $hdir/*_STS.2005010100.nc )
#	#export mf=$( eval ls $hdir/*_SRF.2005010100.nc )
#	export mf=$( eval ls $hdir/*.nc | head -n1 )
#	echo $mf
#	export sea=$s
#	export var=$v
#	ncl -Q $scrdir/apply_RegCM_land_sea_mask.ncl
    mof2=$pdir/${n}_${v}_${ys}_${s}_mean_masked.nc

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
	  if [ $this_o = cru ]; then
		  this_mof=$mof2
	  else
		  this_mof=$mof
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
#      mfr=$pdir/$( basename $mof .nc )_${n}_${this_res}.nc
      mfr=$pdir/$( basename $this_mof .nc )_${n}_${this_res}.nc
      grid=$odir/${n}_${this_o^^}.grid
      ggiuldir=/marconi_work/ICT23_ESP/ggiulian/CORDEX-RegCM-Submit-main/scripts
#      python3 $ggiuldir/griddes_ll.py $mof $this_res > $grid
      python3 $ggiuldir/griddes_ll.py $this_mof $this_res > $grid
      if [ $v = pr ]
      then
        CDO remapnn,$grid $obf $ofr
#        CDO remapnn,$grid $mof $mfr
        CDO remapnn,$grid $this_mof $mfr
      else
        CDO remapdis,$grid $obf $ofr
#        CDO remapdis,$grid $mof $mfr
        CDO remapdis,$grid $this_mof $mfr
      fi
      bof=$pdir/${n}_${v}_${ys}_${s}_bias_${this_o^^}.nc
      echo "Producing $bof"
      CDO sub $mfr $ofr $bof
    done
  done
done

echo "#### process complete! ####"
}
