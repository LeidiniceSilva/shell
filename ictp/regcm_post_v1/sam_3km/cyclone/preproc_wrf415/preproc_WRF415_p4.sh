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
VAR_LIST="AFWA_CAPE_MU AFWA_CIN_MU PSL U10 V10 PREC_ACC_NC" 

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/WRF415"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/cyclone/WRF415"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"
DIR="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v1/sam_3km/cyclone/preproc_wrf415"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    for YEAR in `seq -w 2018 2021`; do
        for MON in `seq -w 01 12`; do

	    if [ ${VAR} == "AFWA_CAPE_MU" ] || [ ${VAR} == "PREC_ACC_NC" ]
	    then
            CDO -setgrid,${DIR}/xlonlat_csam.nc ${DIR_IN}/${VAR}/${VAR}_WRF415_${YEAR}${MON}.nc ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc
	    ${BIN}/./regrid ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
            elif [ ${VAR} == "U10MAX" ] || [ ${VAR} == "V10MAX" ]
            then
            CDO settaxis,${YEAR}-${MON}-01,00:00:00,1day ${DIR_IN}/${VAR}/${VAR}_${YEAR}${MON}_SouthAmerica.nc ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc
            CDO setgrid,${DIR}/xlonlat_sam.nc ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc ${VAR}_${EXP}_${MODEL}_day_${YEAR}${MON}.nc
	    ${BIN}/./regrid ${VAR}_${EXP}_${MODEL}_day_${YEAR}${MON}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
	    else
            cp ${DIR_IN}/${VAR}/${YEAR}${MON}_${VAR}_SouthAmerica.nc ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc
	    ${BIN}/./regrid ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
	    fi

        done
    done

    if [ ${VAR} == "PREC_ACC_NC" ]
    then
    CDO mergetime ${VAR}_${EXP}_${MODEL}_*_lonlat.nc ${VAR}_${EXP}_${MODEL}_1hr_${DT}_lonlat.nc
    CDO daysum ${VAR}_${EXP}_${MODEL}_1hr_${DT}_lonlat.nc ${VAR}_${EXP}_${MODEL}_day_${DT}_lonlat.nc
    elif [ ${VAR} == "U10MAX" ] || [ ${VAR} == "V10MAX" ]
    then
    CDO mergetime ${VAR}_${EXP}_${MODEL}_day_*_lonlat.nc ${VAR}_${EXP}_${MODEL}_day_${DT}_lonlat.nc
    else
    CDO mergetime *_${VAR}_SouthAmerica_lonlat.nc ${VAR}_${EXP}_${MODEL}_1hr_${DT}_lonlat.nc
    CDO selhour,00,06,12,18 ${VAR}_${EXP}_${MODEL}_1hr_${DT}_lonlat.nc ${VAR}_${EXP}_${MODEL}_6hr_${DT}_lonlat.nc
    fi 

done

echo
echo "--------------- THE END POSPROCESSING MODEL -------------"

}
