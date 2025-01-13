#!/bin/bash
#SBATCH -N 1 
#SBATCH -t 9:00:00
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL
#SBATCH -p skl_usr_prod  
#SBATCH --qos=qos_prio

source /marconi/home/userexternal/ggiulian/STACK22/env2022

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

##########################################################
# Run the script by: sbatch postproc_p99.sh domain_name experiment_name
# e.g.  sbatch postproc_p99.sh Africa NoTo

dom=$1
snam=$2-$1
rdir=$3 
odir=$4 
yr=$5

##########################################################

mdir=/marconi_work/ICT23_ESP/ggiulian/OBS/SREX
gdir=/marconi_work/ICT23_ESP/jciarlo0/CORDEX/ERA5/RegCM4

##########################################################

#if [ $# -ne 2 ]
#then
#   echo "Please provide Domain name and conf name in $rdir"
#   echo "Example: $0 Africa NoTo"
#   exit 1
#fi

hdir=$rdir/$snam
if [ ! -d $hdir ]
then
  echo 'Path does not exist: '$hdir
  exit -1
fi

pdir=$hdir/plots
mkdir -p $pdir
outdir=$pdir

# creating file names
filein=$rdir/$snam/pdfs/$dom"_pr_"$yr".nc"
fileout_min=$outdir/prmin_$snam"_"$yr".nc"
fileout_max=$outdir/prmax_$snam"_"$yr".nc"
fileout=$outdir/p99_$snam"_"$yr".nc"
filein_rgcm4=$gdir/$dom/"pr_RegCM4_"$yr".nc"
fileout_min_rgcm4=$outdir/prmin_RegCM4_$dom"_"$yr".nc"
fileout_max_rgcm4=$outdir/prmax_Regcm4_$dom"_"$yr".nc"
fileout_rgcm4=$outdir/p99_RegCM4_$dom"_"$yr".nc"
fileout_regrid_rgcm4=$outdir/regrid_p99_RegCM4_$dom"_"$yr".nc"
fileout_regrid=$outdir/regrid_p99_$snam"_"$yr".nc" 

# Setting Observed and Grid information
obs_grid_name=CRU
obs_name=CPC
#if [ "x$dom" == "xEurope" -o "x$dom" == "Europe03" -o "x$dom" == "WMediterranean" ]; then
#  obs_grid_name=EOBS
#  obs_name=EOBS
#fi
grid="$odir/"$dom"_"$obs_grid_name".grid"
if [ "x$dom" == "xEurope" -o "x$dom" == "xEurope03" -o "x$dom" == "xWMediterranean" ]; then
  obs_grid_name=EUR-HiRes
  obs_name=$obs_grid_name
  hirsdir=/marconi_work/ICT23_ESP/jciarlo0/obs/eur-hires
  gr=03
  dn=$dom
  [[ $dom = Europe ]] && gr=11 && dn=EUR
  [[ $dom = Europe03 ]] && dn=Europe
  [[ $dom = WMediterranean ]] && dn=Medi3
  grid=$hirsdir/pr_p99_${obs_name}_day_${dn}${gr}grid.nc
fi

r4="on"
[[ ! -f $grid ]] && r4="off"
[[ ! -f $grid ]] && grid=$filein

if [ "x$dom" == "xWMediterranean" -o "x$dom" == "xEurope" ]
then
  r4="off"
fi

# p99 and regridding for RegCM5
CDO timmin $filein $fileout_min 
CDO timmax $filein $fileout_max
CDO timpctl,99 $filein $fileout_min $fileout_max $fileout
CDO remapbil,$grid $fileout $fileout_regrid

# p99 and regridding for Regcm4
if [ $r4 = on ]; then
  CDO timmin $filein_rgcm4 $fileout_min_rgcm4 
  CDO timmax $filein_rgcm4 $fileout_max_rgcm4
  CDO timpctl,99 $filein_rgcm4 $fileout_min_rgcm4 \
                 $fileout_max_rgcm4 $fileout_rgcm4
  CDO remapbil,$grid $fileout_rgcm4 $fileout_regrid_rgcm4
fi

# p99 and regridding for Observed
if [ "x$dom" == "xEurope" -o "x$dom" == "xEurope03" -o "x$dom" == "xWMediterranean" ]; then
  obs_grid_name=EUR-HiRes
  obs_name=$obs_grid_name
  hirsdir=/marconi_work/ICT23_ESP/jciarlo0/obs/eur-hires
  gr=03
  dn=$dom
  [[ $dom = Europe ]] && gr=11 && dn=EUR
  [[ $dom = Europe03 ]] && dn=Europe
  [[ $dom = WMediterranean ]] && dn=Medi3
  CDO remapbil,$grid $hirsdir/pr_p99_${obs_name}_day_${dn}${gr}grid.nc \
                   $outdir/regrid_p99_$obs_name"_"$yr".nc"
else
  CDO timmin $odir/pr_$obs_name"_"$yr".nc" $outdir/prmin_$obs_name"_"$yr".nc"
  CDO timmax $odir/pr_$obs_name"_"$yr".nc" $outdir/prmax_$obs_name"_"$yr".nc"
  CDO timpctl,99 $odir/pr_$obs_name"_"$yr".nc" \
        $outdir/prmin_$obs_name"_"$yr".nc" \
        $outdir/prmax_$obs_name"_"$yr".nc" $outdir/p99_$obs_name"_"$yr".nc"
  CDO remapbil,$grid $outdir/p99_$obs_name"_"$yr".nc" \
                   $outdir/regrid_p99_$obs_name"_"$yr".nc"
fi


echo "#### process complete! ####"
}
