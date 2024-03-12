#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 12, 2024'
#__description__ = 'Calculate the p99 of RegCM5 with CDO'
 
{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="2000-2000"

IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

VAR="pr"
EXP="EUR-11"
FOLDER_LIST="Noto-Europe wdm7-Europe wsm5-Europe wsm7-Europe"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for FOLDER in ${FOLDER_LIST[@]}; do

    DIR_IN="/marconi_scratch/userexternal/rnoghero/${FOLDER}"
    DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/EUR-11/post_evaluate/rcm/${FOLDER}"
    BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}

    echo
    echo "1. Select variable: ${VAR}"
    for YEAR in `seq -w ${IYR} ${FYR}`; do
        for MON in `seq -w 01 12`; do
            CDO selname,${VAR} ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
        done
    done

    echo 
    echo "2. Concatenate data"
    CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${EXP}_${FOLDER}_${YR}.nc
    
    echo
    echo "3. Convert unit"
    CDO -b f32 mulc,86400 ${VAR}_${EXP}_${FOLDER}_${YR}.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_${YR}.nc
    
    echo
    echo "4. Calculate p99"
    CDO timmin ${VAR}_${EXP}_${FOLDER}_RegCM5_${YR}.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_${YR}_min.nc
    CDO timmax ${VAR}_${EXP}_${FOLDER}_RegCM5_${YR}.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_${YR}_max.nc
    CDO timpctl,99 ${VAR}_${EXP}_${FOLDER}_RegCM5_${YR}.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_${YR}_min.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_${YR}_max.nc p99_${EXP}_${FOLDER}_RegCM5_${YR}.nc
    
    echo
    echo "5. Regrid variable"
    ${BIN}/./regrid p99_${EXP}_${FOLDER}_RegCM5_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil

done

echo 
echo "6. Delete files"
rm *0100.nc
rm *${YR}.nc
rm *${YR}_min.nc
rm *${YR}_max.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
