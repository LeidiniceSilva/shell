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
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the RegCM5 output with CDO'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="2018-2021"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

EXP="CSAM-4i_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_v1"
VAR_LIST="pr tas sfcWind"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_scratch/SAM-3km/output"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/fps_sesa"
GRID="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v1/sam_3km/evaluate/rcm"
WIND="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts_regcm"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "Select variable"
    for YEAR in `seq -w ${IYR} ${FYR}`; do
        for MON in `seq -w 01 12`; do
            CDO selname,${VAR} ${DIR_IN}/SAM-3km_SRF.${YEAR}${MON}0100.nc ${VAR}_${YEAR}${MON}0100.nc
	    CDO remapdis,${GRID}/grid.txt ${VAR}_${YEAR}${MON}0100.nc ${VAR}_${YEAR}${MON}01.nc
        done
    done
    
    echo 
    echo "Concatenate date"
    CDO mergetime ${VAR}_*01.nc ${VAR}_${YR}.nc

    echo
    echo "Convert unit"
    if [ ${VAR} = 'pr'  ] 
    then
    CDO -b f32 mulc,3600 ${VAR}_${YR}.nc ${VAR}_${EXP}_1hr_${YR}.nc
    elif [ ${VAR} = 'tas'  ] 
    then
    CDO -b f32 mulc,3600 ${VAR}_${YR}.nc ${VAR}_${EXP}_1hr_${YR}.nc
    else
    cp ${VAR}_${YR}.nc ${VAR}_${EXP}_1hr_${YR}.nc
    python3 ${GRID}/rotatewinds.py ${VAR}_${EXP}_1hr_${YR}.nc
    fi

    echo 
    echo "Delete files"
    rm ${VAR}_${EXP}_*01.nc
    rm ${VAR}_${YR}.nc
  
done



echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
