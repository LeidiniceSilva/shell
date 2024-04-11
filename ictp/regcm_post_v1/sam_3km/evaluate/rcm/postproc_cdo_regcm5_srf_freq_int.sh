#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Calculate the freq/int of RegCM5 with CDO'
 
{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="2018-2018"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

VAR="pr"
EXP="SAM-3km"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km_v5/NoTo-SAM"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km_v5/post/rcm"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "1. Select variable: ${VAR}"
for YEAR in `seq -w ${IYR} ${FYR}`; do
    for MON in `seq -w 01 12`; do
        CDO selname,${VAR} ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
    done
done

echo 
echo "2. Concatenate date: ${YR}"
CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${EXP}_${YR}.nc
 
echo
echo "3. Convert unit"
CDO -b f32 mulc,86400 ${VAR}_${EXP}_${YR}.nc ${VAR}_${EXP}_RegCM5_${YR}.nc

echo
echo "4. Frequency and intensity by season"
for SEASON in ${SEASON_LIST[@]}; do
    CDO selseas,${SEASON} ${VAR}_${EXP}_RegCM5_${YR}.nc ${VAR}_${EXP}_RegCM5_${SEASON}_${YR}.nc
    
    CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_RegCM5_${SEASON}_${YR}.nc ${VAR}_freq_${EXP}_RegCM5_${SEASON}_${YR}.nc
    ${BIN}/./regrid ${VAR}_freq_${EXP}_RegCM5_${SEASON}_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

    CDO histmean,1,100000 ${VAR}_${EXP}_RegCM5_${SEASON}_${YR}.nc ${VAR}_int_${EXP}_RegCM5_${SEASON}_${YR}.nc
    ${BIN}/./regrid ${VAR}_int_${EXP}_RegCM5_${SEASON}_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

done

echo 
echo "5. Delete files"
rm *0100.nc
rm *_${YR}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
