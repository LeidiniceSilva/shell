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
VAR_LIST="cli clw hus ua va cl"
SEASON_LIST="DJF MAM JJA SON"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/sam_3km/NoTo-SAM/pressure"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/sam_3km/post"
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
            else
                CDO selname,${VAR} ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100_pressure.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc   
        done
    done	

    echo 
    echo "2. Concatenate data"
    CDO cat ${VAR}_${EXP}_*0100.nc ${VAR}_${EXP}_${DT}.nc 

    echo 
    echo "3. Monthly avg"
    CDO monmean ${VAR}_${EXP}_${DT}.nc ${VAR}_${EXP}_RegCM5_mon_${DT}.nc

    echo 
    echo "4. Regrid output"
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    
    echo
    echo "5. Select levels"
    CDO sellevel,200 ${VAR}_${EXP}_RegCM5_mon_${DT}_lonlat.nc ${VAR}_200hPa_${EXP}_RegCM5_mon_${DT}_lonlat.nc
    CDO sellevel,500 ${VAR}_${EXP}_RegCM5_mon_${DT}_lonlat.nc ${VAR}_500hPa_${EXP}_RegCM5_mon_${DT}_lonlat.nc
    CDO sellevel,850 ${VAR}_${EXP}_RegCM5_mon_${DT}_lonlat.nc ${VAR}_850hPa_${EXP}_RegCM5_mon_${DT}_lonlat.nc
    
    echo
    echo "6. Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        CDO -timmean -selseas,${SEASON} ${VAR}_200hPa_${EXP}_RegCM5_mon_${DT}_lonlat.nc ${VAR}_200hPa_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc
        CDO -timmean -selseas,${SEASON} ${VAR}_500hPa_${EXP}_RegCM5_mon_${DT}_lonlat.nc ${VAR}_500hPa_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc
        CDO -timmean -selseas,${SEASON} ${VAR}_850hPa_${EXP}_RegCM5_mon_${DT}_lonlat.nc ${VAR}_850hPa_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc
    done

done

echo 
echo "7. Delete files"
rm *_${EXP}_*0100.nc
rm *_${EXP}_${DT}.nc
rm *_${EXP}_RegCM5_mon_${DT}.nc
    
echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
