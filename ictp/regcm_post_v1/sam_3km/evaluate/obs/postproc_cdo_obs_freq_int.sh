#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the OBS datasets with CDO'

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

VAR="precip"
DATASET="CPC"
EXP="SAM-3km"
DT="2018-2021"
DT_i="2018-01-01"
DT_ii="2021-12-31"
SEASON_LIST="DJF MAM JJA SON"

DIR_IN="/marconi/home/userexternal/mdasilva/OBS"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_evaluate/obs"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo 
echo "------------------------------- PROCCESSING OBS DATASET -------------------------------"
   
echo
echo "1. Select date"
CDO seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/cpc.day.1979-2021.nc ${VAR}_${EXP}_${DATASET}_${DT}.nc

echo
echo "2. Frequency and intensity by season"
for SEASON in ${SEASON_LIST[@]}; do
    CDO selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}.nc
    
    CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}.nc ${VAR}_freq_${EXP}_${DATASET}_${SEASON}_${DT}.nc
    ${BIN}/./regrid ${VAR}_freq_${EXP}_${DATASET}_${SEASON}_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

    CDO histmean,1,100000 ${VAR}_${EXP}_${DATASET}_${SEASON}_${DT}.nc ${VAR}_int_${EXP}_${DATASET}_${SEASON}_${DT}.nc
    ${BIN}/./regrid ${VAR}_int_${EXP}_${DATASET}_${SEASON}_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
done

echo 
echo "3. Delete files"
rm *_${DT}.nc

}
