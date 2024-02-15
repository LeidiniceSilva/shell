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

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/NoTo-SAM"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_evaluate"
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
echo "4. Calculate p99"
CDO timmin ${VAR}_${EXP}_RegCM5_${DT}.nc ${VAR}_${EXP}_RegCM5_${DT}_min.nc
CDO timmax ${VAR}_${EXP}_RegCM5_${DT}.nc ${VAR}_${EXP}_RegCM5_${DT}_max.nc
CDO timpctl,99 ${VAR}_${EXP}_RegCM5_${DT}.nc ${VAR}_${EXP}_RegCM5_${DT}_min.nc ${VAR}_${EXP}_RegCM5_${DT}_max.nc p99_${EXP}_RegCM5_${DT}.nc
  
echo
echo "5. Regrid variable"
${BIN}/./regrid p99_${EXP}_RegCM5_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo 
echo "6. Delete files"
rm *0100.nc
rm *_${DT}.nc
rm ${VAR}_${EXP}_RegCM5_${DT}_min.nc
rm ${VAR}_${EXP}_RegCM5_${DT}_max.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
