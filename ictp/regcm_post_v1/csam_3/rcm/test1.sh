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

YR="2001-2001"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

EXP="CSAM-3"
VAR_LIST="pr"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/CORDEX/ERA5/ERA5-CSAM3"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/CORDEX/post_evaluate/rcm"
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
        for MON in `seq -w 01 01`; do
	    
	    case $MON in
            01|03|05|07|08|10|12)
                DAYS=31
                ;;
            04|06|09|11)
                DAYS=30
                ;;
            02)
	        DAYS=29
                ;;
	    esac
	
	    for DAY in `seq -w 01 ${DAYS}`; do
	        CDO selname,${VAR} ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}${DAY}00.nc ${VAR}_${EXP}_${YEAR}${MON}${DAY}00.nc	    
	    done  
        done
    done
    
    echo 
    echo "2. Concatenate date: ${YR}"
    CDO mergetime ${VAR}_${EXP}_*00.nc ${VAR}_${EXP}_${YR}${MON}.nc
        
    echo
    echo "3. Convert unit"
    CDO -b f32 mulc,3600 ${VAR}_${EXP}_${YR}${MON}.nc ${VAR}_${EXP}_RegCM5_1hr_${YR}${MON}.nc
    CDO daysum ${VAR}_${EXP}_RegCM5_1hr_${YR}${MON}.nc ${VAR}_${EXP}_RegCM5_day_${YR}${MON}.nc
    
    echo
    echo "4. Regrid output"
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_day_${YR}${MON}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
