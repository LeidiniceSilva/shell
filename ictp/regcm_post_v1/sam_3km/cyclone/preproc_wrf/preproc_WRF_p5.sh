#!/bin/bash

#SBATCH -N 1 
#SBATCH -t 24:00:00
#SBATCH -A ICT23_ESP
#SBATCH --qos=qos_prio
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p skl_usr_prod

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'May 28, 2024'
#__description__ = 'Posprocessing the WRF output with CDO'
 
{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

VAR_LIST="U10e V10e" # MSLP AFWA_CAPE_MU PREC_ACC_NC U10e V10e
EXP="SAM-3km"
MODEL="ECMWF-ERA5_evaluation_r1i1p1f1_UCAR-WRF"
DT="2018-2021"

DIR="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/wrf/wrf/WRF"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do

    DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/wrf/wrf/${VAR}"
    
    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}
    
    for YEAR in `seq -w 2018 2021`; do
        for MON in `seq -w 01 12`; do

            CDO -setgrid,${DIR}/xlonlat.nc ${VAR}_wrf2d_ml_saag_${YEAR}${MON}.nc ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc
	    ${BIN}/./regrid ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
	    #CDO remapbil,${DIR}/grid2.txt ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}_lonlat.nc

        done
    done
        
    if [ ${VAR} == "PREC_ACC_NC" ]
    then
    CDO mergetime ${VAR}_${EXP}_${MODEL}_*_lonlat.nc ${VAR}_${EXP}_${MODEL}_1hr_${DT}_lonlat.nc
    CDO daysum ${VAR}_${EXP}_${MODEL}_1hr_${DT}_lonlat.nc ${VAR}_${EXP}_${MODEL}_day_${DT}_lonlat.nc
    else
    CDO mergetime ${VAR}_${EXP}_${MODEL}_*_lonlat.nc ${VAR}_${EXP}_${MODEL}_1hr_${DT}_lonlat.nc
    CDO selhour,00,06,12,18 ${VAR}_${EXP}_${MODEL}_1hr_${DT}_lonlat.nc ${VAR}_${EXP}_${MODEL}_6hr_${DT}_lonlat.nc
    fi 

done

echo
echo "--------------- THE END POSPROCESSING MODEL -------------"

}


