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
DT="2018-2019"
VAR_LIST="pr tas tasmax tasmin clt hfls hfss rsnl rsns"
SEASON_LIST="DJF MAM JJA SON"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/NoTo-SAM"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "1. Select variable: ${VAR}"
    for YEAR in `seq -w 2018 2019`; do
        for MON in `seq -w 01 12`; do
            if [ ${VAR} = pr  ]
            then
            CDO selname,${VAR} ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	    elif [ ${VAR} = tas  ]
            then
            CDO selname,${VAR} ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	    elif [ ${VAR} = tasmax  ]
            then
            CDO selname,${VAR} ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	    CDO monmean ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_mon_${YEAR}${MON}0100.nc
	    elif [ ${VAR} = tasmin  ]
            then
            CDO selname,${VAR} ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	    CDO monmean ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_mon_${YEAR}${MON}0100.nc
            else
            CDO selname,${VAR} ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	    CDO monmean ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_mon_${YEAR}${MON}0100.nc
	    fi   
        done
    done
    
    echo 
    echo "2. Concatenate data"
    if [ ${VAR} = pr  ]
    then
    CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${EXP}_${DT}.nc
    elif [ ${VAR} = tas  ]
    then
    CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${EXP}_${DT}.nc
    else
    CDO mergetime ${VAR}_${EXP}_mon_*0100.nc ${VAR}_${EXP}_${DT}.nc
    fi
        
    echo
    echo "3. Convert unit"
    if [ ${VAR} = pr  ]
    then
    CDO -b f32 mulc,86400 ${VAR}_${EXP}_${DT}.nc ${VAR}_${EXP}_RegCM5_day_${DT}.nc
    CDO monmean ${VAR}_${EXP}_RegCM5_day_${DT}.nc ${VAR}_${EXP}_RegCM5_mon_${DT}.nc
    elif [ ${VAR} = tas  ]
    then
    CDO -b f32 subc,273.15 ${VAR}_${EXP}_${DT}.nc ${VAR}_${EXP}_RegCM5_day_${DT}.nc
    CDO monmean ${VAR}_${EXP}_RegCM5_day_${DT}.nc ${VAR}_${EXP}_RegCM5_mon_${DT}.nc
    elif [ ${VAR} = tasmax  ]
    then
    CDO -b f32 subc,273.15 ${VAR}_${EXP}_${DT}.nc ${VAR}_${EXP}_RegCM5_mon_${DT}.nc
    elif [ ${VAR} = tasmin  ]
    then
    CDO -b f32 subc,273.15 ${VAR}_${EXP}_${DT}.nc ${VAR}_${EXP}_RegCM5_mon_${DT}.nc
    else
    cp ${VAR}_${EXP}_${DT}.nc ${VAR}_${EXP}_RegCM5_mon_${DT}.nc
    fi
    
    echo
    echo "5. Regrid output"
    if [ ${VAR} = pr  ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_RegCM5_day_${DT}_lonlat.nc ${VAR}_SESA-3km_RegCM5_day_${DT}_lonlat.nc
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_RegCM5_mon_${DT}_lonlat.nc ${VAR}_SESA-3km_RegCM5_mon_${DT}_lonlat.nc
    elif [ ${VAR} = tas  ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_RegCM5_day_${DT}_lonlat.nc ${VAR}_SESA-3km_RegCM5_day_${DT}_lonlat.nc
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_RegCM5_mon_${DT}_lonlat.nc ${VAR}_SESA-3km_RegCM5_mon_${DT}_lonlat.nc
    elif [ ${VAR} = tasmax  ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_RegCM5_mon_${DT}_lonlat.nc ${VAR}_SESA-3km_RegCM5_mon_${DT}_lonlat.nc
    elif [ ${VAR} = tasmin  ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_RegCM5_mon_${DT}_lonlat.nc ${VAR}_SESA-3km_RegCM5_mon_${DT}_lonlat.nc
    else
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    fi

    echo
    echo "6. Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_RegCM5_mon_${DT}_lonlat.nc ${VAR}_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc
    done
done

echo 
echo "7. Delete files"
rm *_${EXP}_*0100.nc
rm *_${DT}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
