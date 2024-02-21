#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 
{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="SAM-3km"
DT="2018-2021"
VAR_LIST="va"
MODEL="ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/NoTo-SAM"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do

    DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/rcm/${VAR}"
    
    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}
    
    for YEAR in `seq -w 2018 2021`; do
        for MON in `seq -w 01 12`; do
	
	    echo
	    echo "1. Select variable: ${VAR}"
	    #CDO selname,${VAR} ${DIR_IN}/pressure/${EXP}_ATM.${YEAR}${MON}0100_pressure.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	    
	    echo
	    echo "2. Select levels"
	    #CDO sellevel,925 ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_925hPa_${EXP}_${MODEL}_6hr_${YEAR}${MON}0100.nc

	    echo
	    echo "3. Regrid"
	    ${BIN}/./regrid ${VAR}_925hPa_${EXP}_${MODEL}_6hr_${YEAR}${MON}0100.nc -35,-15,0.15 -76,-38,0.15 bil

	    echo
	    echo "4. Smooth"
	    CDO smooth ${VAR}_925hPa_${EXP}_${MODEL}_6hr_${YEAR}${MON}0100_lonlat.nc ${VAR}_925hPa_${EXP}_${MODEL}_6hr_${YEAR}${MON}0100_smooth.nc
	    CDO smooth ${VAR}_925hPa_${EXP}_${MODEL}_6hr_${YEAR}${MON}0100_smooth.nc ${VAR}_925hPa_${EXP}_${MODEL}_6hr_${YEAR}${MON}01.nc
	    
	    echo
	    echo "5. Delete files"
	    #rm ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	    rm ${VAR}_925hPa_${EXP}_${MODEL}_6hr_${YEAR}${MON}0100_lonlat.nc
	    rm ${VAR}_925hPa_${EXP}_${MODEL}_6hr_${YEAR}${MON}0100_smooth.nc
    
        done
    done	

done
    
echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
