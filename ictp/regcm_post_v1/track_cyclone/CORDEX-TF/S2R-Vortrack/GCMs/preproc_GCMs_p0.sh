#!/bin/bash

#SBATCH -A CMPNS_ictpclim
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 15, 2024'
#__description__ = 'Postprocessing the dataset with CDO'
 
{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

PATH_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/TRACK-CYCLONE/CORDEX-TF/UKESM1-0-LL/S2R-Vortrack"
PATH_OUT="/leonardo/home/userexternal/mdasilva/leonardo_scratch"

VAR_LIST="ua va"
GCM="UKESM1-0-LL"

for VAR in ${VAR_LIST[@]}; do

    echo
    echo "Mergetime and select level"
    for FILE in ${PATH_IN}/${VAR}_6hrLev_${GCM}_historical_r1i1p1f2_gn_*.nc; do
        BASENAME=$(basename $FILE)
        CDO sellevel,10 $FILE ${PATH_OUT}/sellevel10_${BASENAME}
    done

    CDO mergetime $(ls ${PATH_OUT}/sellevel10_${VAR}_6hrLev_${GCM}_historical_r1i1p1f2_gn_*.nc | sort) \
    ${PATH_OUT}/${VAR}_sellevel10_${GCM}_199901010600-201001010000.nc

    CDO selyear,2000/2009 \
    ${PATH_OUT}/${VAR}_sellevel10_${GCM}_199901010600-201001010000.nc \
    ${PATH_OUT}/${VAR}_6hrLev_${GCM}_historical_r1i1p1f2_gn_200001010000-200912311800.nc

done

}
