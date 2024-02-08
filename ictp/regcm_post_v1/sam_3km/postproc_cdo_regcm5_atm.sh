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
VAR_LIST="cl cli clw hus ua va"
SEASON_LIST="DJF MAM JJA SON"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/NoTo-SAM/pressure"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_evaluate"
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
            if [ ${VAR} = cl  ]
            then
            CDO selname,${VAR} ${DIR_IN}/${EXP}_RAD.${YEAR}${MON}0100_pressure.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	    CDO monmean ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_mon_${YEAR}${MON}0100.nc
            else
            CDO selname,${VAR} ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100_pressure.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	    CDO monmean ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_mon_${YEAR}${MON}0100.nc
	    fi   
        done
    done	

    echo 
    echo "2. Concatenate data: ${DT}"
    CDO mergetime ${VAR}_${EXP}_mon_*0100.nc ${VAR}_${EXP}_RegCM5_mon_${DT}.nc 

    echo 
    echo "3. Regrid output"
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    
    echo
    echo "4. Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        if [ ${VAR} = ua  ]
        then
        CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_RegCM5_mon_${DT}_lonlat.nc ${VAR}_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc
        CDO sellevel,200 ${VAR}_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc ${VAR}_200hPa_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc
        CDO sellevel,500 ${VAR}_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc ${VAR}_500hPa_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc
        CDO sellevel,850 ${VAR}_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc ${VAR}_850hPa_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc
        elif [ ${VAR} = va  ]
        then
        CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_RegCM5_mon_${DT}_lonlat.nc ${VAR}_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc
        CDO sellevel,200 ${VAR}_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc ${VAR}_200hPa_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc
        CDO sellevel,500 ${VAR}_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc ${VAR}_500hPa_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc
        CDO sellevel,850 ${VAR}_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc ${VAR}_850hPa_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc
        elif [ ${VAR} = hus  ]
        then
        CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_RegCM5_mon_${DT}_lonlat.nc ${VAR}_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc
        CDO sellevel,200 ${VAR}_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc ${VAR}_200hPa_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc
        CDO sellevel,500 ${VAR}_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc ${VAR}_500hPa_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc
        CDO sellevel,850 ${VAR}_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc ${VAR}_850hPa_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc
	else
        CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_RegCM5_mon_${DT}_lonlat.nc ${VAR}_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc
	CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc ${VAR}_SESA-3km_RegCM5_${SEASON}_${DT}_lonlat.nc
	fi      
    done   
done

echo 
echo "5. Delete files"
rm *_${EXP}_*0100.nc
rm *_${EXP}_${DT}.nc
rm *_${EXP}_RegCM5_mon_${DT}.nc
    
echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
