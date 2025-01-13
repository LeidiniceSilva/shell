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

dom=$1
snam=$2-$1
rdir=$3 
odir=$4 
tper=$5 

##############################
### change inputs manually ###
##############################

conf=$2
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

r4="on"
special=false
subregs="FullDom"
[[ $dom = Europe         ]] && subregs="MED NEU WCE"
if [ $dom = Europe -a $special = true ]; then
  subregs="CARPAT EURO4M RdisaggH GRIPHO REGNIE ENG-REGR COMEPHORE"
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
[[ $dom = Mediterranean  ]] && subregs="CARPAT EURO4M RdisaggH GRIPHO COMEPHORE" #SPAIN02
[[ $dom = WMediterranean ]] && subregs="EURO4M GRIPHO" #SPAIN02 CARPAT RdisaggH COMEPHORE
[[ $dom = SEEurope       ]] && subregs="GRIPHO COMEPHORE"
[[ $dom = Europe ]] && r4="off"
#[[ $snam = MPI-Europe ]] && r4="off"
#[[ $snam = ERA5-Europe ]] && r4="off"
[[ $lyr -lt 1980 ]] && r4="off"
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

conf=$2
[[ $dom = Europe ]] && gdom=EUR-11
[[ $dom = WMediterranean ]] && gdom=WMD-03
[[ $conf = ERA5 ]] && gcon=ECMWF-ERA5
[[ $conf = MPI ]] && gcon=DKRZ-MPI-ESM1-2-HR
[[ $conf = NorESM ]] && gcon=NCC-NorESM2-MM
[[ $conf = EcEarth ]] && gcon=EC-Earth-Consortium-EC-Earth3-Veg
gsdir=/marconi_scratch/userexternal/jciarlo0/gsstmp/
gssdir=$gsdir

echo "## Processing $dom $fyr - $lyr ##"
for sr in $subregs; do
  echo .. $sr ..

  for v in $vars; do
    [[ $gdom = WMD-03 ]] && gsdir=$hdir/CORDEX/output/$gdom/ICTP/$gcon/*/r*/ICTP-RegCM5-0/v*/day/$v/
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
      # find data
      set +e
      files="$ddir/*_STS.{${fyr}..${lyr}}*.nc"
      firstf=$( eval ls $files 2>/dev/null | head -1 ) 
      [[ ! -z $firstf ]] && iwrk=true || iwrk=false
      gprt="${v}_${gdom}_${gcon}_*_day_"
      gfiles="$gsdir/${gprt}{${fyr}..${lyr}}*.nc"
      [[ $iwrk = false ]] && firstf=$( eval ls $gfiles 2>/dev/null | head -1 )
      [[ -f $firstf ]] && ifdat=true || ifdat=false
      set -e
      if [ $ifdat = false ]; then
        echo "ERROR. Data not found in either directories."
        echo "  ddir=$files"
        echo "  gsdir=$gfiles"
        exit 1
      fi
  
      if [ $iwrk = true ]; then
        for f in $( eval ls $files ); do
          of=$tdir/${dom}_${v}_$( basename $f | cut -d'.' -f2 ).nc
          CDO $func -selvar,$v $f $of
        done
        CDO mergetime $( eval ls $tdir/${dom}_${v}_{${fyr}..${lyr}}????00.nc ) $sof
        rm $( eval ls $tdir/${dom}_${v}_{${fyr}..${lyr}}????00.nc )
      else
        CDO $func -mergetime $( eval ls $gfiles ) $sof
      fi
    fi

    if [ $cp = true ]; then
      pof=$tdir/${pdom}_${v}_${tper}.nc
      if [ ! -f $pof ]; then
        # find data
        set +e
        pfiles="$pdir/*_STS.{${fyr}..${lyr}}*.nc"
        firstf=$( eval ls $pfiles 2>/dev/null | head -1 ) && iwrk=true || iwrk=false
        gprt="${v}_${pdom}_${gcon}_*_day_"
        gpfiles="$gssdir/${gprt}{${fyr}..${lyr}}*.nc"
        [[ $iwrk = false ]] && firstf=$( eval ls $gpfiles 2>/dev/null | head -1 )
        [[ -f $firstf ]] && ifdat=true || ifdat=false
        set -e
        if [ $ifdat = false ]; then
          echo "ERROR. Data not found in either directories."
          echo "  ddir=$pfiles"
          echo "  gsdir=$gpfiles"
          exit 1
        fi

        if [ $iwrk = true ]; then
          for f in $( eval ls $pfiles ); do
            of=$tdir/${pdom}_${v}_$( basename $f | cut -d'.' -f2 ).nc
            CDO $func -selvar,$v $f $of
          done
          CDO mergetime $( eval ls $tdir/${pdom}_${v}_{${fyr}..${lyr}}*00.nc ) $pof
          rm $( eval ls $tdir/${pdom}_${v}_{${fyr}..${lyr}}*00.nc )
        else
          CDO mergetime $( eval ls $gpfiles ) $pof
        fi
      fi
    fi

    if [ $obs = $sr ]; then
      [[ $sr = ENG-REGR     ]] && stim=1990-2010
      [[ $sr = SPAIN02      ]] && stim=1971-2010
      [[ $sr = NORWAY-METNO ]] && stim=1980-2008
      [[ $sr = EURO4M       ]] && stim=1971-2008
      [[ $sr = RADKLIM      ]] && stim=2001-2009
      [[ $sr = COMEPHORE    ]] && stim=1997-2017
      [[ $sr = RdisaggH     ]] && stim=2003-2010
      [[ $sr = GRIPHO       ]] && stim=2001-2016
      st1=$( echo $stim | cut -d- -f1 )
      st2=$( echo $stim | cut -d- -f2 )
      if [ $tper = 1970-1975 ]; then
        [[ $sr = ENG-REGR     ]] && st1=1990 && st2=1995
        [[ $sr = SPAIN02      ]] && st1=1971 && st2=1976
        [[ $sr = NORWAY-METNO ]] && st1=1980 && st2=1985
        [[ $sr = EURO4M       ]] && st1=1971 && st2=1976
        [[ $sr = RADKLIM      ]] && st1=2001 && st2=2006
        [[ $sr = COMEPHORE    ]] && st1=1997 && st2=2002
        [[ $sr = RdisaggH     ]] && st1=2003 && st2=2008
        [[ $sr = GRIPHO       ]] && st1=2001 && st2=2007
      elif [ $tper = 1970-1979 ]; then
        [[ $sr = ENG-REGR     ]] && st1=1990 && st2=1999
        [[ $sr = SPAIN02      ]] && st1=1971 && st2=1980
        [[ $sr = NORWAY-METNO ]] && st1=1980 && st2=1989
        [[ $sr = EURO4M       ]] && st1=1971 && st2=1980
        [[ $sr = RADKLIM      ]] && st1=2001 && st2=2009
        [[ $sr = COMEPHORE    ]] && st1=1997 && st2=2006
        [[ $sr = RdisaggH     ]] && st1=2003 && st2=2010
        [[ $sr = GRIPHO       ]] && st1=2001 && st2=2010
      elif [ $tper = 1980-1989 ]; then
        [[ $sr = ENG-REGR     ]] && st1=1990 && st2=1999
      # [[ $o = SPAIN02      ]] && yf1=1971 && yf2=1980
      # [[ $o = NORWAY-METNO ]] && yf1=1980 && yf2=1989
      # [[ $o = EURO4M       ]] && yf1=1971 && yf2=1980
        [[ $sr = RADKLIM      ]] && st1=2001 && st2=2009
        [[ $sr = COMEPHORE    ]] && st1=1997 && st2=2006
        [[ $sr = RdisaggH     ]] && st1=2003 && st2=2010
        [[ $sr = GRIPHO       ]] && st1=2001 && st2=2010
      elif [ $tper = 1990-1999 ]; then
      # [[ $o = ENG-REGR     ]] && yf1=1990 && yf2=1999
      # [[ $o = SPAIN02      ]] && yf1=1971 && yf2=1980
      # [[ $o = NORWAY-METNO ]] && yf1=1980 && yf2=1989
      # [[ $o = EURO4M       ]] && yf1=1971 && yf2=1980
        [[ $sr = RADKLIM      ]] && st1=2001 && st2=2009
        [[ $sr = COMEPHORE    ]] && st1=1997 && st2=2006
        [[ $sr = RdisaggH     ]] && st1=2003 && st2=2010
        [[ $sr = GRIPHO       ]] && st1=2001 && st2=2010
      elif [ $tper = 1990-1996 ]; then
      # [[ $o = ENG-REGR     ]] && yf1=1990 && yf2=1999
      # [[ $o = SPAIN02      ]] && yf1=1971 && yf2=1980
      # [[ $o = NORWAY-METNO ]] && yf1=1980 && yf2=1989
      # [[ $o = EURO4M       ]] && yf1=1971 && yf2=1980
        [[ $sr = RADKLIM      ]] && st1=2001 && st2=2007
        [[ $sr = COMEPHORE    ]] && st1=1997 && st2=2003
        [[ $sr = RdisaggH     ]] && st1=2003 && st2=2009
        [[ $sr = GRIPHO       ]] && st1=2001 && st2=2007
      elif [ $tper = 2000-2009 ]; then
      # [[ $o = ENG-REGR     ]] && yf1=1990 && yf2=1999
      # [[ $o = SPAIN02      ]] && yf1=1971 && yf2=1980
        [[ $sr = NORWAY-METNO ]] && st1=1999 && st2=2008
        [[ $sr = EURO4M       ]] && st1=1999 && st2=2008
        [[ $sr = RADKLIM      ]] && st1=2001 && st2=2009
      # [[ $o = COMEPHORE    ]] && yf1=1997 && yf2=2006
        [[ $sr = RdisaggH     ]] && st1=2003 && st2=2010
        [[ $sr = GRIPHO       ]] && st1=2001 && st2=2010
      elif [ $tper = 2010-2014 ]; then
        [[ $sr = CARPAT       ]] && st1=2006 && st2=2010
        [[ $sr = ENG-REGR     ]] && st1=2006 && st2=2010
        [[ $sr = SPAIN02      ]] && st1=2006 && st2=2010
        [[ $sr = NORWAY-METNO ]] && st1=2004 && st2=2008
        [[ $sr = EURO4M       ]] && st1=2004 && st2=2008
        [[ $sr = RADKLIM      ]] && st1=2005 && st2=2009
      # [[ $o = COMEPHORE    ]] && yf1=1997 && yf2=2006
        [[ $sr = RdisaggH     ]] && st1=2006 && st2=2010
      # [[ $o = GRIPHO       ]] && yf1=2001 && yf2=2010
        [[ $sr = SWEDEN       ]] && st1=2007 && st2=2011
      elif [ $tper = 1995-1995 ]; then
      # [[ $o = CARPAT       ]] && yf1=1996 && yf2=2010
      # [[ $o = ENG-REGR     ]] && yf1=1996 && yf2=2010
      # [[ $o = SPAIN02      ]] && yf1=2006 && yf2=2010
      # [[ $o = NORWAY-METNO ]] && yf1=2004 && yf2=2008
      # [[ $o = EURO4M       ]] && yf1=2004 && yf2=2008
        [[ $sr = RADKLIM      ]] && st1=2001 && st2=2001
        [[ $sr = COMEPHORE    ]] && st1=1997 && st2=1997
        [[ $sr = RdisaggH     ]] && st1=2003 && st2=2003
        [[ $sr = GRIPHO       ]] && st1=2001 && st2=2001
      # [[ $o = SWEDEN       ]] && yf1=2007 && yf2=2011
      elif [ $tper = 1995-1999 ]; then
      # [[ $o = CARPAT       ]] && yf1=1996 && yf2=2010
      # [[ $o = ENG-REGR     ]] && yf1=1996 && yf2=2010
      # [[ $o = SPAIN02      ]] && yf1=2006 && yf2=2010
      # [[ $o = NORWAY-METNO ]] && yf1=2004 && yf2=2008
      # [[ $o = EURO4M       ]] && yf1=2004 && yf2=2008
        [[ $sr = RADKLIM      ]] && st1=2001 && st2=2005
        [[ $sr = COMEPHORE    ]] && st1=1997 && st2=2001
        [[ $sr = RdisaggH     ]] && st1=2003 && st2=2007
        [[ $sr = GRIPHO       ]] && st1=2001 && st2=2005
      # [[ $o = SWEDEN       ]] && yf1=2007 && yf2=2011
      elif [ $tper = 1995-2004 ]; then
      # [[ $o = CARPAT       ]] && yf1=1996 && yf2=2010
      # [[ $o = ENG-REGR     ]] && yf1=1996 && yf2=2010
      # [[ $o = SPAIN02      ]] && yf1=2006 && yf2=2010
      # [[ $o = NORWAY-METNO ]] && yf1=2004 && yf2=2008
      # [[ $o = EURO4M       ]] && yf1=2004 && yf2=2008
        [[ $sr = RADKLIM      ]] && st1=2001 && st2=2009
        [[ $sr = COMEPHORE    ]] && st1=1997 && st2=2006
        [[ $sr = RdisaggH     ]] && st1=2003 && st2=2010
        [[ $sr = GRIPHO       ]] && st1=2001 && st2=2010
      # [[ $o = SWEDEN       ]] && yf1=2007 && yf2=2011
      elif [ $tper = 2005-2014 ]; then
        [[ $sr = CARPAT       ]] && st1=2001 && st2=2010
        [[ $sr = ENG-REGR     ]] && st1=2001 && st2=2010
        [[ $sr = SPAIN02      ]] && st1=2001 && st2=2010
        [[ $sr = NORWAY-METNO ]] && st1=1999 && st2=2008
        [[ $sr = EURO4M       ]] && st1=1999 && st2=2008
        [[ $sr = RADKLIM      ]] && st1=2001 && st2=2009
      # [[ $o = COMEPHORE    ]] && yf1=1997 && yf2=2006
        [[ $sr = RdisaggH     ]] && st1=2003 && st2=2010
      # [[ $o = GRIPHO       ]] && yf1=2001 && yf2=2010
        [[ $sr = SWEDEN       ]] && st1=2002 && st2=2011
      fi
      tpersr=${st1}-${st2}
      obssrc=$hrdir/${v}_${sr}_day_${stim}.nc
      obsvin=$hrdir/${v}_${sr}_day_${tpersr}.nc
      [[ ! -f $obsvin ]] && CDO selyear,$st1/$st2 $obssrc $obsvin

#      if [ $tper = 2000-2004 ]; then
#        tpersr=$tper
#        [[ $sr = GRIPHO ]] && tpersr=2001-2005
#        [[ $sr = RADKLIM ]] && tpersr=2001-2005
#        [[ $sr = RdisaggH ]] && tpersr=2003-2007
#        obsvin=$hrdir/${v}_${sr}_day_${tpersr}.nc
#      else 
##        if [ $sr = COMEPHORE -o $sr = EURO4M -o $sr = GRIPHO ]; then
##          obsvin=$hrdir/${v}_${sr}_day_${tper}.nc
##          [[ ! -f $obsvin ]] && obsvin=$hrdir/${v}_${sr}_day_XXXX-XXXX.nc
##        else
#          tsel="????-????"
#          [[ $sr = EURO4M ]] && tsel=$tper
#          [[ $sr = GRIPHO ]] && tsel=2001-2016
#          obsvin=$( eval ls $hrdir/${v}_${sr}_day_${tsel}.nc )
#        fi
#      fi
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
