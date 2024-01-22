#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 
{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="SAM-3km"
DT="2018-2021"
SEASON_LIST="DJF MAM JJA SON"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/sam_3km/NoTo-SAM"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/sam_3km/post"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo 
echo "1. Select variable"
for YEAR in `seq -w 2018 2021`; do
    for MON in `seq -w 01 12`; do
    	cdo selname,rsnl ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc rsnl_${EXP}_${YEAR}${MON}0100.nc
    done
done	

echo 
echo "2. Concatenate data"
cdo mergetime rsnl_${EXP}_*0100.nc rsnl_${EXP}_${DT}.nc 

echo 
echo "4. Calculate monthly avg"
cdo monmean rsnl_${EXP}_${DT}.nc rsnl_${EXP}_RegCM5_mon_${DT}.nc

echo 
echo "5. Regrid output"
${BIN}/./regrid rsnl_${EXP}_RegCM5_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo
echo "6. Seasonal avg"
for SEASON in ${SEASON_LIST[@]}; do
    CDO -timmean -selseas,${SEASON} rsnl_${EXP}_RegCM5_mon_${DT}_lonlat.nc rsnl_${EXP}_RegCM5_${SEASON}_${DT}_lonlat.nc
done

echo 
echo "8. Delete files"
rm *_${EXP}_*0100.nc
rm *_${DT}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
