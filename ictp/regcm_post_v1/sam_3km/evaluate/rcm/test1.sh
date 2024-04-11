#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 
{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="2018-2018"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

EXP="SAM-3km"
VAR_LIST="clt rsnl"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km_v5/output"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km_v5/post/rcm"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "1. Select variable: ${VAR}"
    for YEAR in `seq -w ${IYR} ${FYR}`; do
        for MON in `seq -w 01 09`; do
            if [ ${VAR} = 'pr'  ]
            then
            CDO selname,${VAR} ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	    elif [ ${VAR} = 'tas'  ]
            then
            CDO selname,${VAR} ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	    elif [ ${VAR} = 'tasmax'  ]
            then
            CDO selname,${VAR} ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	    CDO monmean ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_mon_${YEAR}${MON}0100.nc
	    elif [ ${VAR} = 'tasmin'  ]
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
    echo "2. Concatenate date: ${YR}"
    if [ ${VAR} = 'pr'  ]
    then
    CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${EXP}_${YR}.nc
    elif [ ${VAR} = 'tas'  ]
    then
    CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${EXP}_${YR}.nc
    else
    CDO mergetime ${VAR}_${EXP}_mon_*0100.nc ${VAR}_${EXP}_${YR}.nc
    fi
        
    echo
    echo "3. Convert unit"
    if [ ${VAR} = 'pr'  ]
    then
    CDO -b f32 mulc,86400 ${VAR}_${EXP}_${YR}.nc ${VAR}_${EXP}_RegCM5_day_${YR}.nc
    CDO monmean ${VAR}_${EXP}_RegCM5_day_${YR}.nc ${VAR}_${EXP}_RegCM5_mon_${YR}.nc
    elif [ ${VAR} = 'tas'  ]
    then
    CDO -b f32 subc,273.15 ${VAR}_${EXP}_${YR}.nc ${VAR}_${EXP}_RegCM5_day_${YR}.nc
    CDO monmean ${VAR}_${EXP}_RegCM5_day_${YR}.nc ${VAR}_${EXP}_RegCM5_mon_${YR}.nc
    elif [ ${VAR} = 'tasmax'  ]
    then
    CDO -b f32 subc,273.15 ${VAR}_${EXP}_${YR}.nc ${VAR}_${EXP}_RegCM5_mon_${YR}.nc
    elif [ ${VAR} = 'tasmin'  ]
    then
    CDO -b f32 subc,273.15 ${VAR}_${EXP}_${YR}.nc ${VAR}_${EXP}_RegCM5_mon_${YR}.nc
    else
    cp ${VAR}_${EXP}_${YR}.nc ${VAR}_${EXP}_RegCM5_mon_${YR}.nc
    fi
    
    echo
    echo "5. Regrid output"
    if [ ${VAR} = 'pr'  ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_day_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_mon_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_RegCM5_day_${YR}_lonlat.nc ${VAR}_SESA-3km_RegCM5_day_${YR}_lonlat.nc
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_RegCM5_mon_${YR}_lonlat.nc ${VAR}_SESA-3km_RegCM5_mon_${YR}_lonlat.nc
    elif [ ${VAR} = 'tas'  ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_day_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_mon_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_RegCM5_day_${YR}_lonlat.nc ${VAR}_SESA-3km_RegCM5_day_${YR}_lonlat.nc
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_RegCM5_mon_${YR}_lonlat.nc ${VAR}_SESA-3km_RegCM5_mon_${YR}_lonlat.nc
    elif [ ${VAR} = 'tasmax'  ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_mon_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_RegCM5_mon_${YR}_lonlat.nc ${VAR}_SESA-3km_RegCM5_mon_${YR}_lonlat.nc
    elif [ ${VAR} = 'tasmin'  ]
    then
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_mon_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    CDO sellonlatbox,-65,-52,-35,-24 ${VAR}_${EXP}_RegCM5_mon_${YR}_lonlat.nc ${VAR}_SESA-3km_RegCM5_mon_${YR}_lonlat.nc
    else
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_mon_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    fi

done

echo 
echo "7. Delete files"
rm *_${EXP}_*0100.nc
rm *_${YR}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
