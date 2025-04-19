#!/bin/bash

#SBATCH -A ICT25_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'May 28, 2024'
#__description__ = 'Posprocessing the WRF output with CDO'
 
{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="SAM-3km"
MODEL="WRF415"
DT="2018-2021"
VAR_LIST=" U10e V10e" 
#VAR_LIST="CAPE CIN_MU PSL U10 V10  U10e V10e PREC_ACC_NC" 

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/WRF415"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/cyclone/WRF415"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"
DIR="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v1/sam_3km/cyclone/preproc_wrf"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    for YEAR in `seq -w 2018 2021`; do
        for MON in `seq -w 01 12`; do

	    if [ ${VAR} == "CAPE" ]
	    then
            CDO -setgrid,${DIR}/xlonlat.nc ${DIR_IN}/${VAR}/wrf2d_cape_saag_ml_${YEAR}${MON}.nc ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc
	    ${BIN}/./regrid ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
	    elif [ ${VAR} == "U10e" ] || [ ${VAR} == "V10e" ] || [ ${VAR} == "U10" ] || [ ${VAR} == "V10" ] || [ ${VAR} == "PREC_ACC_NC" ]
	    then
            CDO -setgrid,${DIR}/xlonlat.nc ${DIR_IN}/WRF2d/wrf2d_ml_saag_${YEAR}${MON}.nc ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc
	    ${BIN}/./regrid ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
	    else
	    ${BIN}/./regrid ${DIR_IN}/${VAR}/${YEAR}${MON}_${VAR}_SouthAmerica.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
	    fi

        done
    done

    if [ ${VAR} == "PREC_ACC_NC" ]
    then
    CDO mergetime ${VAR}_${EXP}_${MODEL}_*.nc ${VAR}_${EXP}_${MODEL}_1hr_${DT}_lonlat.nc
    CDO daysum ${VAR}_${EXP}_${MODEL}_1hr_${DT}_lonlat.nc ${VAR}_${EXP}_${MODEL}_day_${DT}_lonlat.nc
    elif [ ${VAR} == "PSL" ]
    then
    CDO mergetime *_${VAR}_SouthAmerica_lonlat.nc ${VAR}_${EXP}_${MODEL}_1hr_${DT}_lonlat.nc
    CDO selhour,00,06,12,18 ${VAR}_${EXP}_${MODEL}_1hr_${DT}_lonlat.nc ${VAR}_${EXP}_${MODEL}_6hr_${DT}_lonlat.nc
    else
    CDO mergetime ${VAR}_${EXP}_${MODEL}_*.nc ${VAR}_${EXP}_${MODEL}_1hr_${DT}_lonlat.nc
    CDO selhour,00,06,12,18 ${VAR}_${EXP}_${MODEL}_1hr_${DT}_lonlat.nc ${VAR}_${EXP}_${MODEL}_6hr_${DT}_lonlat.nc
    fi 

done

echo
echo "--------------- THE END POSPROCESSING MODEL -------------"

}
