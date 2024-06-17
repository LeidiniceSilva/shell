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

EXP="EUR-11"
VAR_LIST="pr"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/EUR-11/WDM7-Europe"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/EUR-11/post_evaluate/rcm/wdm7-Europe"
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
            CDO selname,${VAR} ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc  
	    
	    	echo
		echo "2. Convert unit"
		CDO -b f32 mulc,86400 ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_RegCM5_${YEAR}${MON}01.nc 
		CDO monmean ${VAR}_${EXP}_RegCM5_${YEAR}${MON}01.nc ${VAR}_${EXP}_RegCM5_${YEAR}${MON}.nc

		echo
		echo "3. Calculate p99, freq and int"
		CDO timmin ${VAR}_${EXP}_RegCM5_${YEAR}${MON}01.nc ${VAR}_${EXP}_RegCM5_${YEAR}${MON}01_min.nc 
		CDO timmax ${VAR}_${EXP}_RegCM5_${YEAR}${MON}01.nc ${VAR}_${EXP}_RegCM5_${YEAR}${MON}01_max.nc 
		CDO timpctl,99 ${VAR}_${EXP}_RegCM5_${YEAR}${MON}01.nc ${VAR}_${EXP}_RegCM5_${YEAR}${MON}01_min.nc ${VAR}_${EXP}_RegCM5_${YEAR}${MON}01_max.nc p99_${EXP}_RegCM5_${YEAR}${MON}01.nc

		CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_RegCM5_${YEAR}${MON}01.nc ${VAR}_freq_${EXP}_RegCM5_${YEAR}${MON}01.nc
		
		CDO histmean,1,100000 ${VAR}_${EXP}_RegCM5_${YEAR}${MON}01.nc ${VAR}_int_${EXP}_RegCM5_${YEAR}${MON}01.nc

		echo
		echo "4. Regrid variable"
		${BIN}/./regrid ${VAR}_${EXP}_RegCM5_${YEAR}${MON}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
		${BIN}/./regrid p99_${EXP}_RegCM5_${YEAR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
		${BIN}/./regrid ${VAR}_freq_${EXP}_RegCM5_${YEAR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
		${BIN}/./regrid ${VAR}_int_${EXP}_RegCM5_${YEAR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
        done
    done 
done

echo 
echo "7. Delete files"
rm *0100.nc
rm *${MON}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
