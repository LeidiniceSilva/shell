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

YR="2000-2009"

VAR_LIST="psl uas vas"
DOMAIN_LIST="AFR AUS CAM EAS EUR NAM SAM WAS"
GCM_LIST="GFDL-ESM4 HadGEM3-GC31-MM MPI-ESM1-2-LR"
#GCM_LIST="CNRM-ESM2-1 EC-Earth3-Veg GFDL-ESM4 HadGEM3-GC31-MM MPI-ESM1-2-HR MPI-ESM1-2-LR NorESM-2MM UKESM1-0-LL"

REMAP="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v1/track_cyclone/CORDEX-TF/S2R-Vortrack/Mask"

echo "--------------- INIT POSPROCESSING DATASET ----------------"

for GCM in ${GCM_LIST[@]}; do

    if [ ${GCM} == "CNRM-ESM2-1" ]; then
	EXP="historical_r1i1p1f2_gr"
    elif [ ${GCM} == "EC-Earth3-Veg" ]; then
        EXP="historical_r1i1p1f1_gr"
    elif [ ${GCM} == "GFDL-ESM4" ]; then
        EXP="historical_r1i1p1f1_gr1"
    elif [ ${GCM} == "HadGEM3-GC31-MM" ]; then
        EXP="historical_r1i1p1f3_gn"
    elif [ ${GCM} == "MPI-ESM1-2-HR" ]; then
        EXP="historical_r1i1p1f1_gn"
    elif [ ${GCM} == "MPI-ESM1-2-LR" ]; then
        EXP="historical_r1i1p1f1_gn"
    elif [ ${GCM} == "NorESM-2MM" ]; then
        EXP="historical_r1i1p1f1_gr1"
    else
        EXP="historical_r1i1p1f1_gr1"
    fi

    for DOMAIN in ${DOMAIN_LIST[@]}; do

	DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/TRACK-CYCLONE/CORDEX-TF/${GCM}/S2R-Vortrack"
        DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/TRACK-CYCLONE/CORDEX-TF/${GCM}/S2R-Vortrack/${DOMAIN}/postproc"

        echo
        cd ${DIR_OUT}
        echo ${DIR_OUT}

        for VAR in ${VAR_LIST[@]}; do

	    echo
	    echo "Regrid and smooth"
            CDO remapbil,${REMAP}/grid_${DOMAIN}.txt ${DIR_IN}/${VAR}_6hrPlevPt_${GCM}_${EXP}_200001010000-200912311800.nc ${VAR}_${GCM}_6hr_${YR}_lonlat.nc
	    CDO smooth ${VAR}_${GCM}_6hr_${YR}_lonlat.nc ${VAR}_${GCM}_6hr_${YR}_smooth.nc
	    CDO smooth ${VAR}_${GCM}_6hr_${YR}_smooth.nc ${VAR}_${GCM}_6hr_${YR}_smooth2.nc

	done
    done
done
    
echo
echo "--------------- THE END POSPROCESSING DATASET ----------------"

}
