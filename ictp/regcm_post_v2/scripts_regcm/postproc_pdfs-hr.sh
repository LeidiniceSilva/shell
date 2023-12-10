#!/bin/bash
#SBATCH -N 1
#SBATCH -t 20:00:00
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL
#SBATCH -p skl_usr_prod
#SBATCH --qos=qos_prio

source /marconi/home/userexternal/ggiulian/STACK22/env2022

##############################
### change inputs manually ###
##############################

dom=$1
snam=$2-$1
rdir=$3 #/marconi_scratch/userexternal/jciarlo0/ERA5
odir=$4 #/marconi_scratch/userexternal/jciarlo0/ERA5/obs
tper=$5 #1999-1999
conf=$2

##############################
### change inputs manually ###
##############################

mdir=/marconi_work/ICT23_ESP/ggiulian/OBS/SREX
gdir=/marconi_work/ICT23_ESP/jciarlo0/CORDEX/ERA5/RegCM4
export SKIP_SAME_TIME=1

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
cpdf(){
  mn=$1 ; mx=$2 ; fin=$3 ; fout=$4
  CDO -b F32 fldsum -timsum -gec,-1000 $fin ${fout}_cnt.nc
  vv=$( basename $fin | cut -d'_' -f1 )
  set +e 
  nc=$( ncdump -v $vv ${fout}_cnt.nc | tail -2 | head -1 | cut -d' ' -f3 )
  set -e
  CDO -b F32 divc,$nc -fldsum -histcount,$( echo $( seq $mn 1 $mx ) | sed 's/ /,/g' ) $fin $fout
  rm ${fout}_cnt.nc
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

special=true
subregs="FullDom"
[[ $dom = Europe         ]] && subregs="MED NEU WCE"
if [ $dom = Europe -a $special = true ]; then
  subregs="RdisaggH GRIPHO RADKLIM COMEPHORE" #"CARPAT EURO4M RdisaggH GRIPHO COMEPHORE REGNIE ENG-REGR"
fi
[[ $dom = Europe03       ]] && subregs="MED NEU WCE"
[[ $dom = NorthAmerica   ]] && subregs="NWN NEN WNA CNA ENA NCA"
[[ $dom = CentralAmerica ]] && subregs="NCA SCA CAR"
[[ $dom = SouthAmerica   ]] && subregs="NWS NSA SAM NES SES SWS SSA"
[[ $dom = Africa         ]] && subregs="SAH WAF CAF NEAF SEAF ARP WSAF ESAF MDG"
[[ $dom = SouthAsia      ]] && subregs="WCA ECA TIB SAS ARP"
[[ $dom = EastAsia       ]] && subregs="ESB RFE ECA TIB EAS"
[[ $dom = SouthEastAsia  ]] && subregs="SEA"
[[ $dom = Australasia    ]] && subregs="NAU CAU EAU SAU NZ"
[[ $dom = Mediterranean  ]] && subregs="RdisaggH GRIPHO COMEPHORE"
[[ $dom = Medi           ]] && subregs="GRIPHO COMEPHORE" 
[[ $dom = WMediterranean ]] && subregs="RdisaggH GRIPHO" # COMEPHORE" 
[[ $dom = SEEurope       ]] && subregs="GRIPHO COMEPHORE"
if [ $dom = Europe -a $special = false -o "$subregs" = "FullDom" -a $special = false ]; then
  obs_p=EOBS
  obs_t=$obs_p
elif [ $dom = Mediterranean -o $dom = WMediterranean -o $dom = Europe03 -o $special = true ]; then
  obs_p=mask
  obs_t=EOBS
  hrdir=/marconi_work/ICT23_ESP/jciarlo0/obs/eur-hires/
  mdir=$hrdir
else 
  obs_p=CPC
  obs_t=CRU
fi

[[ $dom = Europe ]] && gdom=EUR-11
[[ $dom = WMediterranean ]] && gdom=WMD-03
[[ $conf = ERA5 ]] && gcon=ECMWF-ERA5
[[ $conf = MPI ]] && gcon=DKRZ-MPI-ESM1-2-HR
[[ $conf = NorESM ]] && gcon=NCC-NorESM2-MM
[[ $conf = EcEarth ]] && gcon=EC-Earth-Consortium-EC-Earth3-Veg
gdir=/marconi_scratch/userexternal/jciarlo0/gsstmp/

vars="pr"

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
    [[ $gdom = WMD-03 ]] && gdir=$ddir/CORDEX/output/$gdom/ICTP/$gcon/*/r*/ICTP-RegCM5-0/v*/1hr/$v/
   #gdir=$gdir0/$v
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

    sof=$tdir/${dom}_${v}_1hr_${tper}.nc
    [[ $v = pr ]] && func="mulc,3600"
    [[ $v = tas ]] && func="subc,273.15"
    if [ ! -f $sof ]; then
      [[ $cp = true ]] && typ=SRF || typ=SHF
      set +e
      wfiles="$ddir/*_${typ}.{${fyr}..${lyr}}*.nc"
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
          of=$tdir/${dom}_${v}_$( basename $f | cut -d'.' -f2 ).nc
          CDO $func -selvar,$v $f $of
        done
        CDO mergetime $( eval ls $tdir/${dom}_${v}_{${fyr}..${lyr}}*00.nc ) $sof
        rm $( eval ls $tdir/${dom}_${v}_{${fyr}..${lyr}}*00.nc )
      else
        CDO $func -mergetime $( eval ls $gfiles ) $sof
      fi
    fi

    if [ $cp = true ]; then
      pof=$tdir/${pdom}_${v}_1hr_${tper}.nc
      if [ ! -f $pof ]; then
        set +e
        pfiles="$pdir/*_SHF.{${fyr}..${lyr}}*.nc"
        gtmp2=/marconi_scratch/userexternal/jciarlo0/gsstmp/
        pgfiles="$gtmp2/${v}_*_{${fyr}..${lyr}}*.nc"
        firstf=$( eval ls $pfiles 2>/dev/null | head -1 ) && inwork=true || inwork=false
        [[ $inwork = false ]] && firstf=$( eval ls $pgfiles 2>/dev/null | head -1 )
        [[ -f $firstf ]] && ifdat=true || ifdat=false
        set -e
        if [ $ifdat = false ]; then
          echo "ERROR. Parent Data not found in either directories."
          echo "  ddir=$pfiles"
          echo "  gdir=$pgfiles"
          exit 1
        fi 
        if [ $inwork = true ]; then
          for f in $( eval ls $pfiles ); do
            of=$tdir/${pdom}_${v}_$( basename $f | cut -d'.' -f2 ).nc
            CDO $func -selvar,$v $f $of
          done
          CDO mergetime $( eval ls $tdir/${pdom}_${v}_{${fyr}..${lyr}}*00.nc ) $pof
          rm $( eval ls $tdir/${pdom}_${v}_{${fyr}..${lyr}}*00.nc )
        else
          CDO $func -mergetime $( eval ls $pgfiles ) $pof
        fi
      fi
    fi

    if [ $obs = $sr ]; then
      if [ $tper = 2000-2004 ]; then
        tpersr=$tper
        [[ $sr = GRIPHO ]] && tpersr=2001-2005
        [[ $sr = RADKLIM ]] && tpersr=2001-2005
        [[ $sr = RdisaggH ]] && tpersr=2003-2007
        obsvin=$hrdir/${v}_${sr}_1hr_${tpersr}.nc
      elif [ $tper = 1995-1999 ]; then
        tpersr=$tper
        [[ $sr = GRIPHO ]] && tpersr=2001-2005
        [[ $sr = RADKLIM ]] && tpersr=2001-2005
        [[ $sr = RdisaggH ]] && tpersr=2003-2007
        [[ $sr = COMEPHORE ]] && tpersr=1997-2001
        obsvin=$hrdir/${v}_${sr}_1hr_${tpersr}.nc
      else
        if [ $sr = COMEPHORE ]; then
          obsvin=$hrdir/${v}_${sr}_1hr_${tper}.nc
          [[ ! -f $obsvin ]] && obsvin=$hrdir/${v}_${sr}_1hr_XXXX-XXXX.nc
        else
          tsel="????-????"
          [[ $sr = GRIPHO ]] && tsel="2001-2016"
          obsvin=$( eval ls $hrdir/${v}_${sr}_1hr_${tsel}.nc )
        fi
      fi
    else
      obsvin=$odir/${v}_${obs}_${tper}${sup}.nc
    fi
    rcm5in=$sof
    par5in=$pof

    if [ $v = tas -a $obs = CRU ]; then
      rcm5mn=$tdir/${v}_1hr_RegCM5_${sr}_${tper}${sup}_monmean.nc
      [[ ! -f $rcm5mn ]] && CDO monmean $rcm5in $rcm5mn
      rcm5in=$rcm5mn
    fi

    [[ $sr = SPAIN02 ]] && sg="-selgrid,2" || sg=""
    if [ ! -f $mskro ]; then
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
    fi
    ## setting common area: for masks that spill over edge of domain
    if [ ! -f $mskrc ]; then
    CDO remapnn,$rcm5in $mskro $mskrc
    CDO remapnn,$mskro $mskrc ${mskrc}2.nc
    mv ${mskrc}2.nc $mskrc
    fi
    ## end common area

    obsvsb=$tdir/${v}_1hr_${obs}_${sr}_${tper}${sup}_masked.nc
    rcm5sb=$tdir/${v}_1hr_RegCM5_${sr}_${tper}${sup}_masked.nc
    par5sb=$tdir/${v}_1hr_Parent_${sr}_${tper}${sup}_masked.nc
    if [ ! -f $msko ]; then
    CDO ifthen $mskrc $obsvin $obsvsb
    CDO gec,-1000 $obsvsb $msko
    if [ $obs_p = mask ]; then
      CDO timmax $msko ${msko}2.nc
      mv ${msko}2.nc $msko
    fi
    fi
    [[ $v = tas ]] && sg=""
    CDO remapnn,$rcm5in $sg $msko $msk5
    [[ $cp = true ]] && CDO remapnn,$par5in $sg $msko $mskp
    if [ $obs != EOBS ]; then
      CDO seltimestep,1 $msk5 ${msk5}_tmp.nc
      mv ${msk5}_tmp.nc $msk5
    fi
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
    mx5=$( fminmax $rcm5sb $maxf "max" )
    [[ $mxo -ge $mx5 ]] && mxA=$mxo || mxA=$mx5
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
      mn5=$( fminmax $rcm5sb $minf "min" )
      [[ $mno -le $mn5 ]] && mnA=$mno || mnA=$mn5
      if [ $cp = true ]; then
        mnp=$( fminmax $par5sb $minf "min" )
        [[ $mnA -le $mnp ]] && mnA=$mnA || mnA=$mnp
      fi
    fi
    echo $mnA > $mint

    echo $mnA $mxA
    obsvout=$tdir/${v}_1hr_${obs}_${sr}_${tper}${sup}_pdf.nc
    rcm5out=$tdir/${v}_1hr_RegCM5_${sr}_${tper}${sup}_pdf.nc
    par5out=$tdir/${v}_1hr_Parent_${sr}_${tper}${sup}_pdf.nc
    cpdf $mnA $mxA $obsvsb $obsvout
    cpdf $mnA $mxA $rcm5sb $rcm5out
    [[ $cp = true ]] && cpdf $mnA $mxA $par5sb $par5out
  done
done
echo "#### process complete! ####"

}
