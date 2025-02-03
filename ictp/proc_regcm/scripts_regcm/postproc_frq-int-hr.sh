#!/bin/bash
#SBATCH -N 1 
#SBATCH -t 10:00:00
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
rdir=$3 
odir=$4 
ys=$5 
dom=$n
conf=$2

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

pdir=$hdir/plots
mkdir -p $pdir

[[ $dom = Europe ]] && gdom=EUR-11
[[ $dom = WMediterranean ]] && gdom=WMD-03
[[ $conf = ERA5 ]] && gcon=ECMWF-ERA5
[[ $conf = MPI ]] && gcon=DKRZ-MPI-ESM1-2-HR
[[ $conf = NorESM ]] && gcon=NCC-NorESM2-MM
[[ $conf = EcEarth ]] && gcon=EC-Earth-Consortium-EC-Earth3-Veg
gdir=/marconi_scratch/userexternal/jciarlo0/gsstmp/

th=0.5 #threshold 

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
    typ=SRF
    if [ $n = Europe -o $n = Europe03 -o $n = Mediterranean -o $n = WMediterranean ]; then
      o=("hires") && res=("0.03")
      typ=SHF
    elif [ $n = EastAsia ]; then
      o=("cpc" "aphro")
      res=("0.1" "0.25")
    else
      o=("cpc")
      res=("0.1")
    fi

    [[ $gdom = WMD-03 ]] && gdir=$hdir/CORDEX/output/$gdom/ICTP/$gcon/*/r*/ICTP-RegCM5-0/v*/1hr/$v/
      
    echo "#=== $v ===#"
    sof=$pdir/${n}_${v}_1hr_${ys}_${s}.nc
    if [ ! -f $sof ]; then
      set +e 
      wfiles="$hdir/*${typ}.{${fyr}..${lyr}}${mons}*.nc"
      gfiles="$gdir/${v}_*_{${fyr}..${lyr}}*.nc"
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
      if [ $inwork = true ]; then
        for f in $( eval ls $wfiles ); do
          of=$pdir/${n}_${v}_$( basename $f | cut -d'.' -f2 ).nc
          CDO mulc,3600 -selvar,$v $f $of
        done
        CDO mergetime $( eval ls $pdir/${n}_${v}_{${fyr}..${lyr}}${mons}*.nc ) $sof
        ncatted -O -a units,$v,m,c,mm/hr $sof
        rm $( eval ls $pdir/${n}_${v}_{${fyr}..${lyr}}${mons}*.nc )
      else
        sofa=$pdir/${n}_${v}_1hr_${ys}.nc
        [[ ! -f $sofa ]] && CDO mulc,3600 -mergetime $( eval ls $gfiles ) $sofa 
        CDO selmonth,$mmons $sofa $sof
        ncatted -O -a units,$v,m,c,mm/hr $sof
      fi
    fi

#   cof=$pdir/${n}_${v}_1hr_${ys}_${s}_tmp.nc
#   CDO mulc,3600 $sof $cof
#   ncatted -O -a units,$v,m,c,mm/hr $cof
#   mv $cof $sof

    #frequency 
    fof=$pdir/${n}_${v}_1hr_frq_${ys}_${s}_th${th}.nc
  # CDO chname,precipitation_days_index_per_time_period,$v -eca_pd,1 $sof $fof
  # CDO divc,$dy -timsum -gec,0.1 $sof $fof
    CDO mulc,100. -divc,2191.5 -divc,$dy -histcount,$th,100000 $sof $fof
    ncatted -O -a units,$v,m,c,"%" $fof
 
    #intensity
    iof=$pdir/${n}_${v}_1hr_int_${ys}_${s}_th${th}.nc
    CDO histmean,$th,100000 $sof $iof
#   CDO divc,$dy -timsum -mul $sof -gec,0.1 $sof $iof
#   ncatted -O -a units,$v,m,c,"mm/yr" $iof
#   iof2=$pdir/${n}_${v}_int_${ys}_${s}2.nc
#   CDO divc,8766 $iof $iof2
#   mv $iof2 $iof
#   ncatted -O -a units,$v,m,c,"mm/hr" $iof

    no=$(( ${#o[@]} - 1 ))
    echo $o, $no
    for i in `seq 0 $no`; do
      this_o=${o[i]}
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
#       if [ $ys = "2000-2004" ]; then
#         fobs0=$( eval ls $hrdir/${v}_frq_${ys}_${s}_EUR-HiRes_1hr_${nn}${rrr}grid.nc )
#         iobs0=$( eval ls $hrdir/${v}_int_${ys}_${s}_EUR-HiRes_1hr_${nn}${rrr}grid.nc )
        if [ $ys = "1995-1999" ]; then
          fobs0=$( eval ls $hrdir/${v}_frq_${s}_th${th}_EUR-HiRes_1hr_${nn}${rrr}grid_5y.nc )
          iobs0=$( eval ls $hrdir/${v}_int_${s}_th${th}_EUR-HiRes_1hr_${nn}${rrr}grid_5y.nc )
        else
          echo "eur-hi res not prepared"
          exit 1
          fobs0=$( eval ls $hrdir/${v}_frq_${s}_EUR-HiRes_1hr_${nn}${rrr}grid.nc )
          iobs0=$( eval ls $hrdir/${v}_int_${s}_EUR-HiRes_1hr_${nn}${rrr}grid.nc )
        fi
        fobs=$odir/${v}_frq_${this_o^^}_1hr_${ys}_${s}_th${th}.nc
        iobs=$odir/${v}_int_${this_o^^}_1hr_${ys}_${s}_th${th}.nc
        CDO mulc,100. -divc,2191.5 $fobs0 $fobs
        ncatted -O -a units,$v,m,c,"%" $fobs
        cp $iobs0 $iobs
         
        #CDO divc,8766 $iobs0 $iobs
        #ncatted -O -a units,$v,m,c,"mm/hr" $iobs
      else
        echo "not coded for"
        exit 1
        obf=$( eval ls $odir/$obs )
        sobs=$odir/${v}_${this_o^^}_${ys}_${s}.nc
        [[ ! -f $sobs ]] && CDO selseas,$s $obf $sobs

        fobs=$odir/${v}_frq_${this_o^^}_${ys}_${s}.nc
     #  CDO chname,precipitation_days_index_per_time_period,$v -eca_pd,1 $sobs $fobs
        CDO divc,$dy -timsum -gec,1 $sobs $fobs
        ncatted -O -a units,$v,m,c,"days/yr" $fobs

        iobs=$odir/${v}_int_${this_o^^}_${ys}_${s}.nc
        CDO divc,$dy -timsum -mul $sobs -gec,1 $sobs $iobs
        ncatted -O -a units,$v,m,c,"mm/yr" $iobs

        iobs2=$odir/${v}_int_${this_o^^}_${ys}_${s}2.nc
        CDO divc,8766 $iobs $iobs2
        mv $iobs2 $iobs
        ncatted -O -a units,$v,m,c,"mm/hr" $iobs
      fi

      ofr=$odir/$( basename $fobs .nc )_${n}_${this_res}_th${th}.nc
      mfr=$pdir/$( basename $fof .nc )_${n}_${this_res}_th${th}.nc
      CDO remapnn,$grid $fobs $ofr
      CDO remapnn,$grid $fof $mfr
      bof=$pdir/${n}_${v}_1hr_frq_${ys}_${s}_bias_${this_o^^}_th${th}.nc
      echo "Producing $bof"
      CDO sub $mfr $ofr $bof

      ofr=$odir/$( basename $iobs .nc )_${n}_${this_res}_th${th}.nc
      mfr=$pdir/$( basename $iof .nc )_${n}_${this_res}_th${th}.nc
      CDO remapnn,$grid $iobs $ofr
      CDO remapnn,$grid $iof $mfr
      bof=$pdir/${n}_${v}_1hr_int_${ys}_${s}_bias_${this_o^^}_th${th}.nc
      echo "Producing $bof"
      CDO sub $mfr $ofr $bof
    done
  done
done

echo "#### process complete! ####"
}
