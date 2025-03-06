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
#__date__        = 'Nov 20, 2023'
#__description__ = 'Postprocessing the WRF output with CDO'

{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="SAM-3km"
MODEL="WRF"
DT="2018-2021"
VAR_LIST="PSL U10 V10"

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/cyclone/wrf"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "1. Select variable"
for VAR in ${VAR_LIST[@]}; do
    for YEAR in `seq -w 2018 2021`; do
        for MON in `seq -w 01 12`; do

	    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/WRF/${VAR}"
	    
	    echo
	    echo "2. Regrid"
	    ${BIN}/./regrid ${DIR_IN}/${YEAR}${MON}_${VAR}_SouthAmerica.nc -34.5,-15,1.5 -76,-38.5,1.5 bil
	    
	    echo
	    echo "3. Smooth"
	    CDO smooth ${YEAR}${MON}_${VAR}_SouthAmerica_lonlat.nc ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}_smooth.nc
	    CDO smooth ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}_smooth.nc ${VAR}_${EXP}_${MODEL}_${YEAR}${MON}_smooth2.nc
	    	
        done
    done	

    echo
    echo "4. Merge files"   
    CDO mergetime ${VAR}_${EXP}_${MODEL}_*_smooth2.nc ${VAR}_${EXP}_${MODEL}_${DT}_smooth2.nc
    
done
    
echo
echo "--------------- THE END POSPROCESSING MODEL -------------"

}
