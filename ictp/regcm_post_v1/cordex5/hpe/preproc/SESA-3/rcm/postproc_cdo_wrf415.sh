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
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

VAR="PREC_ACC_NC"
EXP="SAAG-WRF415"
DOMAINS="SESA-3"

BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "Select variable"
for DOMAIN in ${DOMAINS[@]}; do

    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/WRF415/${VAR}"
    DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/hpe/input/${DOMAIN}/WRF415"

    cd ${DIR_OUT}
    echo ${DIR_OUT}

    for YEAR in `seq -w 2000 2009`; do

	for MON in `seq -w 01 12`; do
	    cdo settaxis,${YEAR}-${MON}-01,00:00:00,1hour ${DIR_IN}/${YEAR}${MON}_PREC_ACC_NC_SouthAmerica_on-IMERG-grid.nc ${VAR}_${DOMAIN}_${EXP}_${YEAR}${MON}.nc
	    ${BIN}/./regrid ${VAR}_${DOMAIN}_${EXP}_${YEAR}${MON}.nc -36.25,-20.25,0.0275 -65.25,-45.25,0.0275 bil
	done
	
	echo
	echo "Merge files"
	CDO mergetime ${VAR}_${DOMAIN}_${EXP}_${YEAR}*_lonlat.nc ${VAR}_${DOMAIN}_${EXP}_1hr_${YEAR}_lonlat.nc

    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
