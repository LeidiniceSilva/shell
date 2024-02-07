#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Calculate the RegCM5 output diurnal cycle with CDO'
 
{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="SAM-3km"
DT="2018-2021"
VAR_LIST="pr"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/NoTo-SAM"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_evaluate/diurnal_cycle"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "1. Select variable: ${VAR}"
    for YEAR in `seq -w 2018 2021`; do
        for MON in `seq -w 01 12`; do
	    CDO selname,${VAR} ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc

            echo
            echo "2. Convert unit: mm/h"
            CDO -b f32 mulc,3600 ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_CP-RegCM5_${YEAR}${MON}0100.nc
     
	    echo
            echo "3. Regrid variable: ${VAR}"
	    ${BIN}/./regrid ${VAR}_${EXP}_CP-RegCM5_${YEAR}${MON}0100.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
            
	    echo
            echo "4. Select SESA domain"
            CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_CP-RegCM5_${YEAR}${MON}0100_lonlat.nc ${VAR}_SESA-3km_CP-RegCM5_${YEAR}${MON}0100_lonlat.nc
        done
    done
    
    echo 
    echo "5. Merge time: ${DT}"
    CDO mergetime ${VAR}_SESA-3km_CP-RegCM5_*0100_lonlat.nc ${VAR}_SESA-3km_CP-RegCM5_${DT}_lonlat.nc
    
    echo
    echo "6. Hourly mean"
    for HR in `seq -w 00 23`; do
        CDO selhour,${HR} ${VAR}_SESA-3km_CP-RegCM5_${DT}_lonlat.nc ${VAR}_SESA-3km_CP-RegCM5_${HR}_${DT}_lonlat.nc
	CDO timmean ${VAR}_SESA-3km_CP-RegCM5_${HR}_${DT}_lonlat.nc ${VAR}_SESA-3km_CP-RegCM5_${HR}_${DT}_lonlat_timmean.nc
    done
    
    echo
    echo "7. Diurnal cycle"
    CDO mergetime ${VAR}_SESA-3km_CP-RegCM5_*_${DT}_lonlat_timmean.nc ${VAR}_SESA-3km_CP-RegCM5_${DT}_diurnal_cycle.nc
done

echo 
echo "8. Delete files"
rm ${VAR}_*0100.nc
rm ${VAR}_*_lonlat.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
