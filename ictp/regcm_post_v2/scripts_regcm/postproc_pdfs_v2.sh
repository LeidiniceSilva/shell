#!/bin/bash
#SBATCH -N 1
#SBATCH -t 9:00:00
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL
#SBATCH -p skl_usr_prod

source /marconi/home/userexternal/ggiulian/STACK22/env2022

##############################
### change inputs manually ###
##############################

dom=$1
snam=$2-$1
rdir=$3 
odir=$4 
tper=$5 

##############################
### change inputs manually ###
##############################

mdir=/marconi_work/ICT23_ESP/ggiulian/OBS/SREX
gdir=/marconi_work/ICT23_ESP/jciarlo0/CORDEX/ERA5/RegCM4

#if [ $# -ne 2 ]
#then
#   echo "Please provide Domain name and conf name in $rdir"
#   echo "Example: $0 Africa NoTo"
#   exit 1
#fi

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}
CDOf(){
  CDO -b F32 $@
}
cpdf(){
  mn=$1 ; mx=$2 ; fin=$3 ; fout=$4
  CDOf fldsum -timsum -gec,-1000 $fin ${fout}_cnt.nc
  vv=$( basename $fin | cut -d'_' -f1 )
  set +e 
  nc=$( ncdump -v $vv ${fout}_cnt.nc | tail -2 | head -1 | cut -d' ' -f3 )
  set -e
  CDOf divc,$nc -fldsum -histcount,$( echo $( seq $mn 1 $mx ) | sed 's/ /,/g' ) $fin $fout
  rm ${fout}_cnt.nc
}
cpdfy(){
  mn=$1 ; mx=$2 ; fin=$3 ; fout=$4 ; tper=$5
  y1=$( echo $tper | cut -d- -f1 )
  y2=$( echo $tper | cut -d- -f2 )
  nn=0
  for y in $( seq $y1 $y2 ); do
   CDOf selyear,$y $fin ${fout}_y${y}.nc
   CDOf fldsum -timsum -gec,-1000 ${fout}_y${y}.nc ${fout}_cnt.nc
   vv=$( basename $fin | cut -d'_' -f1 )
   set +e
   nc=$( ncdump -v $vv ${fout}_cnt.nc | tail -2 | head -1 | cut -d' ' -f3 )
   set -e
   nn=$( awk "BEGIN { print $nn + $nc }" )
   CDOf fldsum -histcount,$( echo $( seq $mn 1 $mx ) | sed 's/ /,/g' ) ${fout}_y${y}.nc ${fout}_p${y}.nc
   rm ${fout}_cnt.nc ${fout}_y${y}.nc
  done
  eval CDOf divc,$nc -enssum ${fout}_p{${y1}..${y2}}.nc $fout
  rm ${fout}_p{${y1}..${y2}}.nc
}

fyr=$( echo $tper | cut -d- -f1 )
lyr=$( echo $tper | cut -d- -f2 )
focus=yr 
[[ $focus = yr ]] && sup="" || sup="_${focus}"

cp=false
if [ $dom = "WMediterranean" -o $dom = "Europe03" ]; then
  cp=true
fi
if [ $cp = true ]; then
  parentin=${snam}.in
  pdir=$( cat $parentin | grep coarse_outdir | cut -d"'" -f2 )
  pdom=$( cat $parentin | grep coarse_domname | cut -d"'" -f2 )
fi

r4="off"
special=true
subregs="SAM"
[[ $dom = SouthAmerica         ]] && subregs="SAM"
if [ $dom = Europe -a $special = true ]; then
  subregs="CARPAT EURO4M RdisaggH GRIPHO REGNIE ENG-REGR COMEPHORE"
fi
[[ $dom = Europe03       ]] && subregs="MED NEU WCE"
[[ $dom = NorthAmerica   ]] && subregs="NWN NEN WNA CNA ENA NCA"
[[ $dom = CentralAmerica ]] && subregs="NCA SCA CAR"
[[ $dom = SouthAmerica   ]] && subregs="SAM"
#[[ $dom = SouthAmerica   ]] && subregs="NWS NSA SAM NES SES SWS SSA"
[[ $dom = Africa         ]] && subregs="SAH WAF CAF NEAF SEAF ARP WSAF ESAF MDG"
[[ $dom = SouthAsia      ]] && subregs="WCA ECA TIB SAS ARP"
[[ $dom = EastAsia       ]] && subregs="ESB RFE ECA TIB EAS"
[[ $dom = SouthEastAsia  ]] && subregs="SEA"
[[ $dom = Australasia    ]] && subregs="NAU CAU EAU SAU NZ"
[[ $dom = Mediterranean  ]] && subregs="CARPAT EURO4M RdisaggH GRIPHO COMEPHORE" #SPAIN02
[[ $dom = WMediterranean ]] && subregs="EURO4M GRIPHO" #SPAIN02 CARPAT RdisaggH COMEPHORE
[[ $dom = SEEurope       ]] && subregs="GRIPHO COMEPHORE"
[[ $snam = MPI-Europe ]] && r4="off"

[[ "$subregs" = "FullDom" ]] && r4="off"
if [ $dom = Europe -a $special = false -o "$subregs" = "FullDom" -a $special = false ]; then
  obs_p=EOBS
  obs_t=$obs_p
elif [ $dom = Mediterranean -o $dom = Europe03 -o $dom = WMediterranean -o $special = true ]; then
  obs_p=mask
  obs_t=EOBS
  hrdir=/marconi_work/ICT23_ESP/jciarlo0/obs/eur-hires/
  mdir=$hrdir
  r4="off"
else 
  obs_p=CPC
  obs_t=CRU
fi
vars="pr tas"

fdir=$gdir/$dom
ddir=$rdir/$snam
tdir=$ddir/pdfs
if [ ! -d $ddir ]; then
  echo 'Path does not exist: '$ddir
  exit -1
fi
mkdir -p $tdir

echo "## Processing $dom $fyr - $lyr ##"
for sr in $subregs; do
  echo .. $sr ..

  for v in $vars; do
    echo .. .. $v ..
    [[ $v = pr  ]] && obs=$obs_p
    [[ $v = tas ]] && obs=$obs_t
    [[ $obs = mask ]] && obs=$sr

    if [ $sr = FullDom ]; then
      set +e
      tempsrc=$( ls $ddir/*STS*.nc | head -1 )
      set -e
      mskf=$tdir/${sr}_mask0.nc
      CDO gec,-1 -selvar,mask $tempsrc $mskf
    else
      mskf=$mdir/${sr}_mask.nc
    fi
    mski=$tdir/${sr}.info
    mskf2=$tdir/${sr}_mask.nc
    mskro=$tdir/${sr}_mask-${obs}-grid.nc
    mskrc=$tdir/${sr}_mask-${obs}-common.nc
    msk4=$tdir/${sr}-${obs}_mask-RegCM4-grid.nc
    msk5=$tdir/${sr}-${obs}_mask-RegCM5-grid.nc
    mskp=$tdir/${sr}-${obs}_mask-Parent-grid.nc
    msko=$tdir/${sr}-${obs}_mask-${obs}-grid.nc

    sof=$tdir/${dom}_${v}_${tper}.nc
    [[ $v = pr ]] && func="mulc,86400"
    [[ $v = tas ]] && func="subc,273.15"
    if [ ! -f $sof ]; then
      for f in $( eval ls $ddir/*_STS.{${fyr}..${lyr}}*.nc ); do
        of=$tdir/${dom}_${v}_$( basename $f | cut -d'.' -f2 ).nc
        CDO $func -selvar,$v $f $of
      done
      CDO mergetime $( eval ls $tdir/${dom}_${v}_{${fyr}..${lyr}}????00.nc ) $sof
      rm $( eval ls $tdir/${dom}_${v}_{${fyr}..${lyr}}????00.nc )
    fi

    if [ $cp = true ]; then
      pof=$tdir/${pdom}_${v}_${tper}.nc
      if [ ! -f $pof ]; then
        for f in $( eval ls $pdir/*_STS.{${fyr}..${lyr}}*.nc ); do
          of=$tdir/${pdom}_${v}_$( basename $f | cut -d'.' -f2 ).nc
          CDO $func -selvar,$v $f $of
        done
        CDO mergetime $( eval ls $tdir/${pdom}_${v}_{${fyr}..${lyr}}*00.nc ) $pof
        rm $( eval ls $tdir/${pdom}_${v}_{${fyr}..${lyr}}*00.nc )
      fi
    fi

    if [ $obs = $sr ]; then
      if [ $tper = 2000-2004 ]; then
        tpersr=$tper
        [[ $sr = GRIPHO ]] && tpersr=2001-2005
        [[ $sr = RADKLIM ]] && tpersr=2001-2005
        [[ $sr = RdisaggH ]] && tpersr=2003-2007
        obsvin=$hrdir/${v}_${sr}_day_${tpersr}.nc
      else 
        if [ $sr = COMEPHORE ]; then
          obsvin=$hrdir/${v}_${sr}_day_${tper}.nc
          [[ ! -f $obsvin ]] && obsvin=$hrdir/${v}_${sr}_day_XXXX-XXXX.nc
        else
          obsvin=$( eval ls $hrdir/${v}_${sr}_day_????-????.nc )
        fi
      fi
    else
      obsvin=$odir/${v}_${obs}_${tper}${sup}.nc
    fi
    rcm4in=$fdir/${v}_RegCM4_${tper}${sup}.nc
    rcm5in=$sof
    par5in=$pof

    if [ $v = tas -a $obs = CRU ]; then
      rcm4mn=$tdir/${v}_RegCM4_${sr}_${tper}${sup}_monmean.nc
      rcm5mn=$tdir/${v}_RegCM5_${sr}_${tper}${sup}_monmean.nc
      [[ $r4 = on ]] && CDO monmean $rcm4in $rcm4mn
      CDO monmean $rcm5in $rcm5mn
      rcm4in=$rcm4mn
      rcm5in=$rcm5mn
    fi

    [[ $sr = SPAIN02 ]] && sg="-selgrid,2" || sg=""
    if [ $sr = SPAIN02 ]; then
#     mskro=$mskf
#   elif [ $v = tas -a $sr = SPAIN02 ]; then
      CDO remapnn,$obsvin $sg $mskf $mskro
    else
      CDO griddes $mskf > $mski
      sed -i "s/generic/lonlat/g" $mski
      CDO setgrid,$mski $mskf $mskf2
      CDO remapnn,$obsvin $mskf2 $mskro
      rm $mski $mskf2
    fi
    ## setting common area: for masks that spill over edge of domain
    CDO remapnn,$rcm5in $mskro $mskrc
    CDO remapnn,$mskro $mskrc ${mskrc}2.nc
    mv ${mskrc}2.nc $mskrc
    ## end common area

    obsvsb=$tdir/${v}_${obs}_${sr}_${tper}${sup}_masked.nc
    rcm4sb=$tdir/${v}_RegCM4_${sr}_${tper}${sup}_masked.nc
    rcm5sb=$tdir/${v}_RegCM5_${sr}_${tper}${sup}_masked.nc
    par5sb=$tdir/${v}_Parent_${sr}_${tper}${sup}_masked.nc
    CDO ifthen $mskrc $obsvin $obsvsb
    CDO gec,-1000 $obsvsb $msko
    if [ $obs_p = mask ]; then
      CDO timmax $msko ${msko}2.nc
      mv ${msko}2.nc $msko
    fi
    [[ $r4 = on ]] && CDO remapnn,$rcm4in $msko $msk4
    [[ $v = tas ]] && sg=""
    CDO remapnn,$rcm5in $sg $msko $msk5
    [[ $cp = true ]] && CDO remapnn,$par5in $sg $msko $mskp
    if [ $obs != EOBS ]; then
      [[ $r4 = on ]] && CDO seltimestep,1 $msk4 ${msk4}_tmp.nc
      CDO seltimestep,1 $msk5 ${msk5}_tmp.nc
      [[ $r4 = on ]] && mv ${msk4}_tmp.nc $msk4
      mv ${msk5}_tmp.nc $msk5
    fi
    [[ $r4 = on ]] && CDO ifthen $msk4 $rcm4in $rcm4sb
    CDO ifthen $msk5 $rcm5in $rcm5sb 
    [[ $cp = true ]] && CDO ifthen $mskp $par5in $par5sb

    fminmax(){
      f=$1 ; xf=$2 ; mnmx=$3
      CDO fld${mnmx} -tim${mnmx} $f $xf >/dev/null 2>/dev/null
      nx=$( ncdump -v $v $xf | tail -2 | head -1 | cut -d' ' -f3 )
      /usr/bin/printf '%.*f\n' 0 $nx
      rm $xf
    } 

    maxf=$tdir/${v}_max.nc
    maxt=$tdir/${v}_max.txt
    mxo=$( fminmax $obsvsb $maxf "max" )
    [[ $r4 = on ]] && mx4=$( fminmax $rcm4sb $maxf "max" )
    mx5=$( fminmax $rcm5sb $maxf "max" )
    [[ $mxo -ge $mx5 ]] && mxA=$mxo || mxA=$mx5
    if [ $r4 = on ]; then
      [[ $mxA -ge $mx4 ]] && mxA=$mxA || mxA=$mx4
    fi
    if [ $cp = true ]; then
      mxp=$( fminmax $par5sb $maxf "max" )
      [[ $mxA -ge $mxp ]] && mxA=$mxA || mxA=$mxp
    fi
    echo $mxA > $maxt

    minf=$tdir/${v}_min.nc
    mint=$tdir/${v}_min.txt
    if [ $v = pr ]; then
      mnA=0
    else
      mno=$( fminmax $obsvsb $minf "min" )
      [[ $r4 = on ]] && mn4=$( fminmax $rcm4sb $minf "min" )
      mn5=$( fminmax $rcm5sb $minf "min" )
      [[ $mno -le $mn5 ]] && mnA=$mno || mnA=$mn5
      if [ $r4 = on ]; then
        [[ $mnA -le $mn4 ]] && mnA=$mnA || mnA=$mn4
      fi
      if [ $cp = true ]; then
        mnp=$( fminmax $par5sb $minf "min" )
        [[ $mnA -le $mnp ]] && mnA=$mnA || mnA=$mnp
      fi
    fi
    echo $mnA > $mint

    echo $mnA $mxA
    obsvout=$tdir/${v}_${obs}_${sr}_${tper}${sup}_pdf.nc
    rcm4out=$tdir/${v}_RegCM4_${sr}_${tper}${sup}_pdf.nc
    rcm5out=$tdir/${v}_RegCM5_${sr}_${tper}${sup}_pdf.nc
    par5out=$tdir/${v}_Parent_${sr}_${tper}${sup}_pdf.nc
    if [ "${obs}_${sr}" = "COMEPHORE_COMEPHORE" ]; then 
      cpdfy $mnA $mxA $obsvsb $obsvout $tper
    else
      cpdf $mnA $mxA $obsvsb $obsvout
    fi
    [[ $r4 = on ]] && cpdf $mnA $mxA $rcm4sb $rcm4out
    cpdf $mnA $mxA $rcm5sb $rcm5out
    [[ $cp = true ]] && cpdf $mnA $mxA $par5sb $par5out
  done
done
echo "#### process complete! ####"

}
