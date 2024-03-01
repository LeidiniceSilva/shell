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

DATASET="ERA5"
VAR_LIST="tp"
EXP="SAM-3km"
DT="2018-2021"
DT_i="2018-01-01"
DT_ii="2021-12-31"

DIR_IN="/marconi/home/userexternal/mdasilva/OBS"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_evaluate/obs"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo 
echo "------------------------------- PROCCESSING ERA5 DATASET -------------------------------"

for VAR in ${VAR_LIST[@]}; do

    echo
    echo "1. Select date"
    CDO seldate,${DT_i},${DT_ii} ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_1hr_2018-2021.nc ${VAR}_${DATASET}_${DT}.nc
    
    echo
    echo "2. Convert unit"
    if [ ${VAR} == 'tp' ]
    then
    CDO -b f32 mulc,1000 ${VAR}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_${DT}.nc
    else
    CDO -b f32 subc,273.15 ${VAR}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_${DT}.nc
    fi
    
    echo
    echo "4. Hourly mean"
    for HR in `seq -w 00 23`; do
    
        CDO selhour,${HR} ${VAR}_${EXP}_${DATASET}_${DT}.nc ${VAR}_${EXP}_${DATASET}_${HR}hr_${DT}.nc
	CDO timmean ${VAR}_${EXP}_${DATASET}_${HR}hr_${DT}.nc ${VAR}_${EXP}_${DATASET}_${HR}hr_${DT}_timmean.nc
	
    done
    
    echo
    echo "5. Diurnal cycle"
    CDO mergetime ${VAR}_${EXP}_${DATASET}_*hr_${DT}_timmean.nc ${VAR}_${EXP}_${DATASET}_diurnal_cycle_${DT}.nc
   
    echo
    echo "6. Regrid output"
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_diurnal_cycle_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
              
done

echo 
echo "7. Delete files"
rm *_${DT}.nc
rm *_${DT}_timmean.nc

}
