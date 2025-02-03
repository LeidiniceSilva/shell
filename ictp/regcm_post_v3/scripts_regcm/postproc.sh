#!/bin/bash

#SBATCH -A ICT23_ESP_1
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1 
#SBATCH -t 4:00:00
#SBATCH --ntasks-per-node=108
#SBATCH --mail-type=FAIL

# module purge
source /leonardo/home/userexternal/ggiulian/modules_gfortran

##############################
### change inputs manually ###
##############################

n=$1
path=$2-$1
rdir=$3 
odir=$4 
ys=$5 
scrdir=$6

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

dom=$n
conf=$2
[[ $dom = Europe ]] && gdom=EUR-11
[[ $dom = WMediterranean ]] && gdom=WMD-03
[[ $conf = ERA5 ]] && gcon=ECMWF-ERA5
[[ $conf = MPI ]] && gcon=DKRZ-MPI-ESM1-2-HR
[[ $conf = NorESM ]] && gcon=NCC-NorESM2-MM
[[ $conf = EcEarth ]] && gcon=EC-Earth-Consortium-EC-Earth3-Veg
gdir=/marconi_scratch/userexternal/jciarlo0/gsstmp/

pdir=$hdir/plots
mkdir -p $pdir

seas="DJF MAM JJA SON"
vars="pr tas tasmax tasmin clt"

#if [ $n = Europe -o $n = NorthAmerica -o $n = EastAsia ]; then
#  vars="$vars snw"
#fi

for s in $seas ; do
  echo "#### post-processing $n $s $ys ####"
  [[ $s = DJF ]] && mons="{12,01,02}" && mmons="12,01,02"
  [[ $s = MAM ]] && mons="{03,04,05}" && mmons="03,04,05"
  [[ $s = JJA ]] && mons="{06,07,08}" && mmons="06,07,08"
  [[ $s = SON ]] && mons="{09,10,11}" && mmons="09,10,11"

  for v in $vars; do
    echo "#=== $v ===#"
    [[ $v = pr     ]] && o=("mswep" "cpc" "gpcc" 'cru' "gpcp" "era5") && res=("0.1" "0.1" "0.25" "0.5" "0.5" "0.25")
    [[ $v = tas    ]] && o=("cru" "era5") && res=("0.5" "0.25")
    [[ $v = tasmax ]] && o=("cru") && res=("0.5")
    [[ $v = tasmin ]] && o=("cru") && res=("0.5")
    [[ $v = clt    ]] && o=("cru" "era5") && res=("0.5" "0.25")
    # [[ $v = snw    ]] && o=("swe") && res=("1.0")
	
	# domain-specific adjustments
    [[ $gdom = WMD-03 ]] && gdir=$hdir/CORDEX/output/$gdom/ICTP/$gcon/*/r*/ICTP-RegCM5-0/v*/day/$v/
    if [ $n = Europe -o $n = Europe03 ]; then
      [[ $v = pr     ]] && o+=("eobs") && res+=("0.1")
      [[ $v = tas    ]] && o+=("eobs") && res+=("0.1")
      [[ $v = tasmax ]] && o+=("eobs") && res+=("0.1")
      [[ $v = tasmin ]] && o+=("eobs") && res+=("0.1")
    elif [ $n = Mediterranean -o $n = SEEurope -o $n = WMediterranean ]; then
      [[ $v = pr     ]] && o=("eobs" "mswep") && res=("0.1" "0.1")
      [[ $v = tas    ]] && o=("eobs") && res=("0.1")
    fi
	# printf "%s\n" "${o[@]}"
	# printf "%s\n" "${res[@]}"

    typ=STS
    [[ $v = clt ]] && typ=SRF
    [[ $v = snw ]] && typ=SRF

    # find data
    set +e
    files="$hdir/*${typ}.{${fyr}..${lyr}}${mons}*.nc" 
    #firstf=$( eval ls $files 2>/dev/null | head -1 ) && iwrk=true || iwrk=false
	files="`eval ls $files `"
	firstf="$( echo $files | cut -d " " -f 1)"
	#[[ ! -z $firstf ]] && iwrk=true || iwrk=false
	[[ -f $firstf ]] && iwrk=true || iwrk=false
    gprt="${v}_${gdom}_${gcon}_*_day_"
    gfiles="$gdir/${gprt}{${fyr}..${lyr}}${mons}*.nc"
    [[ $gdom = WMD-03 ]] && gfiles="$gdir/${gprt}{${fyr}..${lyr}}*.nc"
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
      [[ $v = clt ]] && func="daymean -selvar,$v"
      [[ $v = snw ]] && func="daymean -selvar,$v"
      for f in $( eval ls $files ); do
        of=$pdir/${n}_${v}_$( basename $f | cut -d'.' -f2 ).nc
        CDO $func $f $of
      done
      CDO mergetime $( eval ls $pdir/${n}_${v}_{${fyr}..${lyr}}${mons}*.nc ) $sof
      rm $( eval ls $pdir/${n}_${v}_{${fyr}..${lyr}}${mons}*.nc )
    else
      CDO mergetime $( eval ls $gfiles ) $sof
      if [ $gdom = WMD-03 ]; then
        CDO selmonth,$mmons $sof ${sof}_${s}tmp.nc
        mv ${sof}_${s}tmp.nc $sof
      fi
    fi

    # mof=$pdir/${n}_${v}_${ys}_${s}_mean.nc
    mof=$pdir/${v}_RegCM_${ys}_${s}_mean.nc
    CDO timmean $sof $mof
    rm $sof

    if [ $v = pr ]; then
      cof=$pdir/${n}_${v}_${ys}_${s}_mean_tmp.nc
      CDO mulc,86400 $mof $cof
      ncatted -O -a units,pr,m,c,mm/day $cof
      mv $cof $mof
    elif [ $v = tas -o $v = tasmax -o $v = tasmin ]; then
      cof=$pdir/${n}_${v}_${ys}_${s}_mean_tmp.nc
      CDO subc,273.15 $mof $cof
      ncatted -O -a units,$v,m,c,Celsius $cof
      mv $cof $mof
    fi

	# apply land-sea mask
	export mf=$( eval ls $hdir/*.nc | grep -v "clm" | head -n1 )
	echo $mf
	export sea=$s
	export var=$v
	ncl -Q $scrdir/apply_RegCM_land_sea_mask.ncl
    mof2=$pdir/${v}_RegCM_${ys}_${s}_mean_masked.nc

    no=$(( ${#o[@]} - 1 ))
    echo $o, $no
    for i in `seq 0 $no`; do
      this_o=${o[i]}
      if [ $this_o = cpc -a $fyr -lt 1979 ]; then
        continue
      fi
      if [ $this_o = mswep -a $fyr -lt 1980 ]; then
        continue
      fi
      this_res=${res[i]}
      if [ $n = Europe03 -a $this_o = hires ]; then
        this_res=0.03
      fi
      echo "#--- processing ${this_o^^} with resolution of ${this_res} ---#"
      obs="${v}_${this_o^^}_${ys}_${s}_mean.nc"
      if [ $this_o = "hires" ]; then
        hrdir=/marconi_work/ICT23_ESP/jciarlo0/obs/eur-hires
        [[ $n = Europe ]] && nn=EUR || nn=$n
        [[ $n = Europe03 ]] && nn=Europe 
        [[ $n = WMediterranean ]] && nn=Medi3 
        rrr=$( echo $this_res | cut -d. -f2 )
        if [ $ys = "2000-2004" ]; then
          obf=$( eval ls $hrdir/${v}_mean_${ys}_${s}_EUR-HiRes_day_${nn}${rrr}grid.nc )
        else
          obf=$( eval ls $hrdir/${v}_mean_${s}_EUR-HiRes_day_${nn}${rrr}grid.nc )
        fi
      else
        obf=$( eval ls $odir/$obs )
      fi
      ofr=$pdir/$( basename $obf .nc )_${n}_${this_res}.nc
      mfr=$pdir/$( basename $mof .nc )_${n}_${this_res}.nc
      mfr2=$pdir/$( basename $mof2 .nc )_${n}_${this_res}.nc
      grid=$pdir/${n}_${this_o^^}.grid
      if [ ! -f $grid ]; then
        python3 $scrdir/griddes_ll.py $mof $this_res > $grid
      fi
      if [ $v = pr ]
      then
        CDO remapnn,$grid $obf $ofr
        CDO remapnn,$grid $mof $mfr
        CDO remapnn,$grid $mof2 $mfr2
      else
        CDO remapdis,$grid $obf $ofr
        CDO remapdis,$grid $mof $mfr
        CDO remapdis,$grid $mof2 $mfr2
      fi
      bof=$pdir/${v}_bias_${ys}_${s}_${this_o^^}.nc
      bof2=$pdir/${v}_bias_${ys}_${s}_${this_o^^}_masked.nc
      echo "Producing $bof"
      CDO sub $mfr $ofr $bof
      CDO sub $mfr2 $ofr $bof2
    done
  done
done

echo "#### process complete! ####"
}
