#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Calculate the p99 of RegCM5 with CDO'
 
{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

VAR="pr"
EXP="SAM-3km"
DT="2018-2021"
SEASON_LIST="DJF MAM JJA SON"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/NoTo-SAM"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_evaluate/rcm"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "1. Select variable: ${VAR}"
for YEAR in `seq -w 2018 2021`; do
    for MON in `seq -w 01 12`; do
        CDO selname,${VAR} ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
    done
done

echo 
echo "2. Merge time: ${DT}"
CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${EXP}_${DT}.nc
 
echo
echo "3. Convert unit"
CDO -b f32 mulc,86400 ${VAR}_${EXP}_${DT}.nc ${VAR}_${EXP}_RegCM5_${DT}.nc

echo
echo "4. Frequency and intensity by season"
for SEASON in ${SEASON_LIST[@]}; do
    CDO selseas,${SEASON} ${VAR}_${EXP}_RegCM5_${DT}.nc ${VAR}_${EXP}_RegCM5_${SEASON}_${DT}.nc
    
    CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_RegCM5_${SEASON}_${DT}.nc ${VAR}_freq_${EXP}_RegCM5_${SEASON}_${DT}.nc
    ${BIN}/./regrid ${VAR}_freq_${EXP}_RegCM5_${SEASON}_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

    CDO histmean,1,100000 ${VAR}_${EXP}_RegCM5_${SEASON}_${DT}.nc ${VAR}_int_${EXP}_RegCM5_${SEASON}_${DT}.nc
    ${BIN}/./regrid ${VAR}_int_${EXP}_RegCM5_${SEASON}_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

done

echo 
echo "5. Delete files"
rm *0100.nc
rm *_${DT}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
