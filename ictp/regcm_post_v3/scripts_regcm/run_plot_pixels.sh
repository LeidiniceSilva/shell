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
#mkdir -p $pdir

[[ $snum = Europe         ]] && subregs="MED NEU WCE"
[[ $snum = NorthAmerica   ]] && subregs="NWN NEN WNA CNA ENA NCA"
[[ $snum = CentralAmerica ]] && subregs="NCA SCA CAR"
[[ $snum = SouthAmerica   ]] && subregs="NWS NSA SAM NES SES SWS SSA"
[[ $snum = Africa         ]] && subregs="SAH WAF CAF NEAF SEAF ARP WSAF ESAF MDG"
[[ $snum = SouthAsia      ]] && subregs="WCA ECA TIB SAS ARP"
[[ $snum = EastAsia       ]] && subregs="ESB RFE ECA TIB EAS"
#[[ $snum = EastAsia       ]] && subregs="EAS"
[[ $snum = SouthEastAsia  ]] && subregs="SEA"
[[ $snum = Australasia    ]] && subregs="NAU CAU EAU SAU NZ"
[[ $snum = Mediterranean  ]] && subregs="CARPAT SPAIN02 EURO4M COMEPHORE RdisaggH GRIPHO"
[[ $snum = Medi           ]] && subregs="CARPAT EURO4M COMEPHORE GRIPHO"
[[ $snum = Medi3          ]] && subregs="CARPAT SPAIN02 EURO4M COMEPHORE RdisaggH GRIPHO"
[[ $snum = SEEurope       ]] && subregs="COMEPHORE GRIPHO"

for s in $subregs; do
  echo "#=== $s ===#"
  # calc
  echo "#--- calculating ${s} ---#"
  export s
  ncl -Q $scrdir/calc_pixels.ncl
done

echo "#### plot complete! ####"
}
