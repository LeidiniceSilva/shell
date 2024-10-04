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

YR="2000-2000"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

CONF=$1
EXP="EUR-11"
VAR_LIST="cl cli clw"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/EUR-11/${CONF}"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/EUR-11/postproc/rcm"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "1. Select variable"
for VAR in ${VAR_LIST[@]}; do
    for YEAR in `seq -w ${IYR} ${FYR}`; do
        for MON in `seq -w 01 01`; do

            if [ ${VAR} = 'cl'  ]
            then
            CDO selname,${VAR} ${DIR_IN}/pressure/${EXP}_RAD.${YEAR}${MON}0100_pressure.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	    CDO monmean ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_${CONF}_${YEAR}${MON}.nc
            else
            CDO selname,${VAR} ${DIR_IN}/pressure/${EXP}_ATM.${YEAR}${MON}0100_pressure.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	    CDO monmean ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_${CONF}_${YEAR}${MON}.nc
	    fi 
	    
	    echo
	    echo "2. Regrid variable"
	    ${BIN}/./regrid ${VAR}_${EXP}_${CONF}_${YEAR}${MON}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	    
	    CDO sellonlatbox,1,16,40,50 ${VAR}_${EXP}_${CONF}_${YEAR}${MON}_lonlat.nc ${VAR}_${EXP}_FPS_${CONF}_${YEAR}${MON}_lonlat.nc

        done
    done 
done

echo 
echo "Delete files"
rm *0100.nc
rm *01.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
