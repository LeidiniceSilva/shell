#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 12, 2024'
#__description__ = 'Calculate the freq/int of RegCM5 with CDO'
 
{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="2000-2001"

IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

VAR="pr"
EXP="EUR-11"
SEASON_LIST="DJF MAM JJA SON"
FOLDER_LIST="NoTo-Europe WDM7-Europe WSM7-Europe WSM5-Europe"

echo
echo "--------------- INIT POSTPROCESSING MODEL ----------------"

for FOLDER in ${FOLDER_LIST[@]}; do

    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/${FOLDER}"
    DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/postproc/rcm"
    BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

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
    echo "4. Frequency and intensity by season"
    for SEASON in ${SEASON_LIST[@]}; do
	CDO selseas,${SEASON} ${VAR}_${EXP}_${FOLDER}_RegCM5_${YR}.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_${SEASON}_${YR}.nc
        CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_${FOLDER}_RegCM5_${SEASON}_${YR}.nc ${VAR}_freq_${EXP}_${FOLDER}_RegCM5_${SEASON}_${YR}.nc
        ${BIN}/./regrid ${VAR}_freq_${EXP}_${FOLDER}_RegCM5_${SEASON}_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
        CDO histmean,1,100000 ${VAR}_${EXP}_${FOLDER}_RegCM5_${SEASON}_${YR}.nc ${VAR}_int_${EXP}_${FOLDER}_RegCM5_${SEASON}_${YR}.nc
	${BIN}/./regrid ${VAR}_int_${EXP}_${FOLDER}_RegCM5_${SEASON}_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
    done

done

echo 
echo "5. Delete files"
rm *0100.nc
rm *${YR}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
