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

TH=0.5 
VAR="tp"
DATASET="ERA5"
EXP="SAM-3km"
DT="2018-2021"
DT_i="2018-01-01"
DT_ii="2021-12-31"
SEASON_LIST="DJF MAM JJA SON"

FDT=$( echo $DT | cut -d- -f1 )
LDT=$( echo $DT | cut -d- -f2 )
DY=$(( $LDT - $FDT + 1 ))

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
CDO mulc,1000 ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_1hr_${DT}.nc ${VAR}_${EXP}_${DATASET}_1hr_${DT}.nc

echo
echo "2. Frequency and intensity by season"
for SEASON in ${SEASON_LIST[@]}; do
    CDO selseas,${SEASON} ${VAR}_${EXP}_${DATASET}_1hr_${DT}.nc ${VAR}_${EXP}_${DATASET}_1hr_${SEASON}_${DT}.nc
    
    CDO mulc,100 -histfreq,${TH},100000 ${VAR}_${EXP}_${DATASET}_1hr_${SEASON}_${DT}.nc ${VAR}_freq_${EXP}_${DATASET}_1hr_${SEASON}_${DT}_th${TH}.nc
    ${BIN}/./regrid ${VAR}_freq_${EXP}_${DATASET}_1hr_${SEASON}_${DT}_th${TH}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

    CDO histmean,${TH},100000 ${VAR}_${EXP}_${DATASET}_1hr_${SEASON}_${DT}.nc ${VAR}_int_${EXP}_${DATASET}_1hr_${SEASON}_${DT}_th${TH}.nc
    ${BIN}/./regrid ${VAR}_int_${EXP}_${DATASET}_1hr_${SEASON}_${DT}_th${TH}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
done

echo 
echo "3. Delete files"
rm *_${DT}.nc
rm *_th${TH}.nc

}