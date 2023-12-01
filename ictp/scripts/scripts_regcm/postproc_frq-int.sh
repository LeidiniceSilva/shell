#!/bin/bash
#SBATCH -N 1 
#SBATCH -t 9:00:00
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL
#SBATCH -p skl_usr_prod
#SBATCH --qos=qos_prio

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
dy=$(( $lyr - $fyr + 1 ))

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
[[ $conf = ERA5 ]] && gcon=ECMWF-ERA5
[[ $conf = MPI ]] && gcon=DKRZ-MPI-ESM1-2-HR
[[ $conf = NorESM ]] && gcon=NCC-NorESM2-MM
[[ $conf = EcEarth ]] && gcon=EC-Earth-Consortium-EC-Earth3-Veg
gdir=/marconi_scratch/userexternal/jciarlo0/gsstmp/

pdir=$hdir/plots
mkdir -p $pdir

seas="DJF MAM JJA SON"
vars="pr"
#vars=snw
for s in $seas ; do
  echo "#### post-processing $n $s $ys ####"
  [[ $s = DJF ]] && mons="{12,01,02}" && mmons="12,01,02"
  [[ $s = MAM ]] && mons="{03,04,05}" && mmons="03,04,05"
  [[ $s = JJA ]] && mons="{06,07,08}" && mmons="06,07,08"
  [[ $s = SON ]] && mons="{09,10,11}" && mmons="09,10,11"

  for v in $vars; do
    [[ $gdom = WMD-03 ]] && gdir=$hdir/CORDEX/output/$gdom/ICTP/$gcon/*/r*/ICTP-RegCM5-0/v*/day/$v/
    if [ $n = Europe -o $n = Europe03 -o $n = Mediterranean -o $n = WMediterranean ]; then
      o=("hires" "eobs" "cpc" "gpcc") && res=("0.03" "0.1" "0.1" "0.25")
    elif [ $n = EastAsia ]; then
      o=("cpc" "gpcc" "aphro")
      res=("0.1" "0.25" "0.25")
    else
      o=("cpc" "gpcc")
      res=("0.1" "0.25")
    fi
      
    echo "#=== $v ===#"
    typ=STS

    # find data
    set +e
    files="$hdir/*${typ}.{${fyr}..${lyr}}${mons}*.nc"
    firstf=$( eval ls $files 2>/dev/null | head -1 ) && iwrk=true || iwrk=false
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
      for f in $( eval ls $files ); do
        of=$pdir/${n}_${v}_$( basename $f | cut -d'.' -f2 ).nc
        CDO mulc,86400 -selvar,$v $f $of
      done
      CDO mergetime $( eval ls $pdir/${n}_${v}_{${fyr}..${lyr}}${mons}*.nc ) $sof
      ncatted -O -a units,$v,m,c,mm/day $sof
      rm $( eval ls $pdir/${n}_${v}_{${fyr}..${lyr}}${mons}*.nc )
    else
      sofa=$pdir/${n}_${v}_day_${ys}.nc
#      if [ ! -f $sofa ]; then
        CDO mulc,86400 -mergetime $( eval ls $gfiles ) $sofa
        ncatted -O -a units,$v,m,c,mm/day $sofa
#      fi
      CDO selseason,$s $sofa $sof
#      if [ $gdom = WMD-03 ]; then
#        CDO selmonth,$mmons $sofa $sof
#      fi
    fi

#   cof=$pdir/${n}_${v}_${ys}_${s}_tmp.nc
#   CDO mulc,86400 $sof $cof
#   ncatted -O -a units,$v,m,c,mm/day $cof
#   mv $cof $sof

    #frequency 
    fof=$pdir/${n}_${v}_frq_${ys}_${s}.nc
  # CDO chname,precipitation_days_index_per_time_period,$v -eca_pd,1 $sof $fof
  # CDO mulc,100. -divc,91.3 -divc,$dy -histcount,1,100000 $sof $fof
    CDO mulc,100 -histfreq,1,100000 $sof $fof
  # CDO divc,$dy -timsum -gec,1 $sof $fof
    ncatted -O -a units,$v,m,c,"%" $fof
 
    #intensity
    iof=$pdir/${n}_${v}_int_${ys}_${s}.nc
    CDO histmean,1,100000 $sof $iof
#   CDO divc,$dy -timsum -mul $sof -gec,1 $sof $iof
#   ncatted -O -a units,$v,m,c,"mm/yr" $iof
#   iof2=$pdir/${n}_${v}_int_${ys}_${s}2.nc
#   CDO divc,365.25 $iof $iof2
#   mv $iof2 $iof
#   ncatted -O -a units,$v,m,c,"mm/day" $iof

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
      if [ $this_o = gpcc -a $fyr -lt 1982 ]; then
        continue
      fi
      this_res=${res[i]}
      if [ $this_o = hires -a $n = Europe ]; then
        this_res=0.11
      fi
      echo "#--- processing ${this_o^^} with resolution of ${this_res} ---#"

      grid=$odir/${n}_${this_o^^}.grid
      ggiuldir=/marconi_work/ICT23_ESP/ggiulian/CORDEX-RegCM-Submit-main/scripts
      [[ ! -f $grid ]] && python3 $ggiuldir/griddes_ll.py $fof $this_res > $grid

      obs="${v}_${this_o^^}_${ys}.nc"
      if [ $this_o = "hires" ]; then
        hrdir=/marconi_work/ICT23_ESP/jciarlo0/obs/eur-hires
        [[ $n = Europe ]] && nn=EUR || nn=$n
        [[ $n = Europe03 ]] && nn=Europe 
        [[ $n = WMediterranean ]] && nn=Medi3 
        rrr=$( echo $this_res | cut -d. -f2 )
#       if [ $ys = "2000-2004" -o $ys = "1970-1975" ]; then
          fobs0=$( eval ls $hrdir/${v}_frq_${ys}_${s}_EUR-HiRes_day_${nn}${rrr}grid.nc )
          iobs0=$( eval ls $hrdir/${v}_int_${ys}_${s}_EUR-HiRes_day_${nn}${rrr}grid.nc )
#       else
#         fobs0=$( eval ls $hrdir/${v}_frq_${s}_EUR-HiRes_day_${nn}${rrr}grid.nc )
#         iobs0=$( eval ls $hrdir/${v}_int_${s}_EUR-HiRes_day_${nn}${rrr}grid.nc )
#       fi
        fobs=$odir/${v}_frq_${this_o^^}_${ys}_${s}.nc
        iobs=$odir/${v}_int_${this_o^^}_${ys}_${s}.nc
#       CDO mulc,100. -divc,91.3 $fobs0 $fobs
        cp $fobs0 $fobs
        ncatted -O -a units,$v,m,c,"%" $fobs
        cp $iobs0 $iobs

        #CDO divc,365.25 $iobs0 $iobs
        #ncatted -O -a units,$v,m,c,"mm/day" $iobs
      else
        obf=$( eval ls $odir/$obs )
        sobs=$odir/${v}_${this_o^^}_${ys}_${s}.nc
        [[ ! -f $sobs ]] && CDO selseas,$s $obf $sobs

        fobs=$odir/${v}_frq_${this_o^^}_${ys}_${s}.nc
     #  CDO chname,precipitation_days_index_per_time_period,$v -eca_pd,1 $sobs $fobs
     #  CDO mulc,100. -divc,91.3 -divc,$dy -histcount,1,100000 $sobs $fobs
        CDO mulc,100. -histfreq,1,100000 $sobs $fobs
     #  CDO divc,$dy -timsum -gec,1 $sobs $fobs
        ncatted -O -a units,$v,m,c,"%" $fobs

        iobs=$odir/${v}_int_${this_o^^}_${ys}_${s}.nc
        CDO histmean,1,100000 $sobs $iobs
  #     CDO divc,$dy -timsum -mul $sobs -gec,1 $sobs $iobs
  #     ncatted -O -a units,$v,m,c,"mm/yr" $iobs
  #     iobs2=$odir/${v}_int_${this_o^^}_${ys}_${s}2.nc
  #     CDO divc,365.25 $iobs $iobs2
  #     mv $iobs2 $iobs
        ncatted -O -a units,$v,m,c,"mm/day" $iobs
      fi

      ofr=$odir/$( basename $fobs .nc )_${n}_${this_res}.nc
      mfr=$pdir/$( basename $fof .nc )_${n}_${this_res}.nc
      CDO remapnn,$grid $fobs $ofr
      CDO remapnn,$grid $fof $mfr
      bof=$pdir/${n}_${v}_frq_${ys}_${s}_bias_${this_o^^}.nc
      echo "Producing $bof"
      CDO sub $mfr -selvar,$v $ofr $bof

      ofr=$odir/$( basename $iobs .nc )_${n}_${this_res}.nc
      mfr=$pdir/$( basename $iof .nc )_${n}_${this_res}.nc
      CDO remapnn,$grid $iobs $ofr
      CDO remapnn,$grid $iof $mfr
      bof=$pdir/${n}_${v}_int_${ys}_${s}_bias_${this_o^^}.nc
      echo "Producing $bof"
      CDO sub $mfr -selvar,$v $ofr $bof
    done
  done
done

echo "#### process complete! ####"
}
