#!/bin/bash
#SBATCH -N 1 
#SBATCH -t 8:00:00
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=clu@ictp.it
#SBATCH -p skl_usr_prod

source /marconi/home/userexternal/ggiulian/STACK22/env2022

##############################
### change inputs manually ###
##############################

n=$1
path=$2-$1
export snum=$1
export conf=$2
rdir=$3      #/marconi_scratch/userexternal/jciarlo0/ERA5
export scrdir=$4    #/marconi/home/userexternal/jciarlo0/regcm_tests/Atlas2
export ys=$5 #1999-1999

##############################
####### end of inputs ########
##############################

export REMAP_EXTRAPOLATE=off

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

mdir=/marconi_work/ICT23_ESP/ggiulian/OBS/SREX
odir=${rdir}/obs

#if [ $# -ne 2 ]
#then
#   echo "Please provide Domain name and conf name in $rdir"
#   echo 'Example: $0 Africa "NoTo"'
#   echo 'Example: $0 Africa "NoTo WSM"'
#   echo 'Currently only support up to 6 configurations...'
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

#ff=$hdir/*.nc
#if [ -z "$ff" ]
#then
#  echo 'No files: '$ff
#  exit -1
#fi

pdir=$hdir/plots
#pdir=$rdir/Taylor_diagram
mkdir -p $pdir
mkdir -p $pdir/txt_files

vars="pr tas tasmax tasmin clt"
#vars="tas"
#if [ $n = Europe -o $n = NorthAmerica -o $n = EastAsia ]; then
#  vars="$vars snw"
#fi

[[ $snum = Europe         ]] && subregs="MED NEU WCE"
[[ $snum = Europe03       ]] && subregs="MED NEU WCE"
[[ $snum = NorthAmerica   ]] && subregs="NWN NEN WNA CNA ENA NCA"
[[ $snum = CentralAmerica ]] && subregs="NCA SCA CAR"
[[ $snum = SouthAmerica   ]] && subregs="NWS NSA SAM NES SES SWS SSA"
[[ $snum = Africa         ]] && subregs="SAH WAF CAF NEAF SEAF ARP WSAF ESAF MDG"
[[ $snum = SouthAsia      ]] && subregs="WCA ECA TIB SAS ARP"
[[ $snum = EastAsia       ]] && subregs="ESB RFE ECA TIB EAS"
[[ $snum = SouthEastAsia  ]] && subregs="SEA"
[[ $snum = Australasia    ]] && subregs="NAU CAU EAU SAU NZ"
#[[ $snum = Mediterranean  ]] && subregs="CARPAT SPAIN02 EURO4M COMEPHORE RdisaggH GRIPHO"
#[[ $snum = Medi           ]] && subregs="CARPAT EURO4M COMEPHORE GRIPHO"
[[ $snum = WMediterranean ]] && subregs="CARPAT SPAIN02 EURO4M COMEPHORE RdisaggH GRIPHO"
[[ $snum = SEEurope       ]] && subregs="COMEPHORE GRIPHO"

for v in $vars; do
  export var=$v
  if [ $n = Europe -o $n = Europe03 ]; then
    if [ $fyr -lt 1979 ]; then
      [[ $v = pr     ]] && o="hires eobs gpcc" && res="0.11 0.1 0.25"
    else
      [[ $v = pr     ]] && o="eobs mswep cpc gpcc era5 cru" && res="0.1 0.1 0.1 0.25 0.25 0.5"
    fi
    [[ $v = tas    ]] && o="eobs era5 cru" && res="0.1 0.25 0.5"
  elif [ $n = SEEurope -o $n = WMediterranean ]; then
    if [ $fyr -lt 1979 ]; then
      [[ $v = pr     ]] && o="hires eobs" && res="0.03 0.1"
    else
      [[ $v = pr     ]] && o="hires eobs mswep" && res="0.03 0.1 0.1"
    fi
    [[ $v = tas    ]] && o=eobs && res=0.1
  elif [ $n = EastAsia ]; then
    [[ $v = pr     ]] && o="mswep cpc gpcc aphro cn05.1 era5 cru" && res="0.1 0.1 0.25 0.25 0.25 0.25 0.5"
    [[ $v = tas    ]] && o="cru aphro cn05.1 era5" && res="0.5 0.25 0.25 0.25"
  else
    [[ $v = pr     ]] && o="mswep cpc gpcc cru era5" && res="0.1 0.1 0.25 0.5 0.25"
    [[ $v = tas    ]] && o="cru era5" && res="0.5 0.25"
  fi
  [[ $v = tasmax ]] && o="cru era5" && res="0.5 0.25"
  [[ $v = tasmin ]] && o="cru era5" && res="0.5 0.25"
  [[ $v = clt    ]] && o="cru era5" && res="0.5 0.25"
  [[ $v = snw    ]] && o=swe && res=1.0
  echo "#=== $v ===#"
  # create subregion mask for each obs dataset
  for this_o in $o; do
    echo "#--- processing ${this_o^^} ---#"
    grid=$odir/${n}_${this_o^^}.grid
    for sr in $subregs; do
      eurhires=false
      if [ $sr = CARPAT -o $sr = SPAIN02 -o $sr = EURO4M -o $sr = COMEPHORE -o $sr = RdisaggH -o $sr = GRIPHO ]; then
        eurhires=true
      fi
      [[ $eurhires = true ]] && mdir=/marconi_work/ICT23_ESP/jciarlo0/obs/eur-hires/
      echo "#### ### ... $sr ... ### ####"
      if [ $sr = FullDom ]; then
        mskf=$tdir/${sr}_mask0.nc
      else
       mskf=$mdir/${sr}_mask.nc
      fi
      mski=$pdir/${sr}.info
      mskf2=$pdir/${sr}_mask.nc
      mskfo=$pdir/${sr}-${this_o^^}_mask.nc
#      if [ $sr != SPAIN02 ]; then
#        CDO griddes $mskf > $mski
#        sed -i "s/generic/lonlat/g" $mski
#        CDO setgrid,$mski $mskf $mskf2
#        CDO remapnn,$grid $mskf2 $mskfo
#        rm $mski $mskf2
#      else
#        CDO remapnn,$grid -selgrid,2 $mskf $mskfo
#      fi
      if [ $eurhires = true ]; then
        CDO chname,pr,mask $mskfo ${mskfo}2.nc
        set +e
        tdim=$( ncdump -h ${mskfo}2.nc | grep -i time | grep mask | head -1 | cut -d'(' -f2 | cut -d, -f1 )
        ncwa -O -a $tdim ${mskfo}2.nc $mskfo | grep -v WARNING
        set -e
        rm ${mskfo}2.nc
      fi
    done
    if [ $this_o = hires -a $v = pr ]; then
      echo "#--- adjusting data for ${this_o^^} $v ---#"
      [[ $snum = Europe ]] && nn=EUR || nn=$n
      [[ $snum = WMediterranean ]] && nn=Medi3
      [[ $snum = Europe ]] && rrr=11 || rrr=03
      [[ $snum = Europe ]] && rr0=0.11 || rr0=0.03
      seas="DJF MAM JJA SON"
      for s in $seas; do
        sdir=/marconi_work/ICT23_ESP/jciarlo0/obs/eur-hires/
        ehrf=$sdir/${v}_mean_${s}_EUR-HiRes_day_${nn}${rrr}grid.nc
        nhrf=$odir/${v}_${this_o^^}_${ys}_${s}_mean_${snum}_${rr0}.nc
        modf=$pdir/${snum}_${v}_${ys}_${s}_mean_${snum}_${rr0}.nc
#        CDO remapnn,$modf $ehrf $nhrf
      done
    fi
  done
  # plot
  echo "#--- plotting ${conf}, ${o^^} ---#"
  export obs=${o^^}
  export ress=$res
  export subregs
  ncl -Q $scrdir/plot_taylor_diagram_v2.ncl

  # loop over obs dataset(s) to calc stats
  for this_o in $o; do
	  echo "#--- calculating ${conf}, ${this_o^^} ---#"
	  # plot
	  export obs=${this_o^^}
      [[ $this_o = gpcc   ]] && export res=0.25
      [[ $this_o = aphro  ]] && export res=0.25
      [[ $this_o = cn05.1 ]] && export res=0.25
      [[ $this_o = cru    ]] && export res=0.5
      [[ $this_o = hires  ]] && export res=0.11
      [[ $this_o = eobs   ]] && export res=0.1
      [[ $this_o = mswep  ]] && export res=0.1
      [[ $this_o = cpc    ]] && export res=0.1
      [[ $this_o = era5   ]] && export res=0.25
      [[ $this_o = swe    ]] && export res=1.0
	  export ress=$res
	  export subregs
	  ncl -Q $scrdir/calc_taylor_diagram_stats.ncl
  done
done

echo "#### plot complete! ####"
}
