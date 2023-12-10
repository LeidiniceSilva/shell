#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

EXP="SAM-3km"

DT="2018-2021"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/sam_3km/NoTo-SAM"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/sam_3km/postproc"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo 
echo "1. Select variable"

for YEAR in `seq -w 2018 2018`; do
    for MON in `seq -w 01 12`; do

    	cdo selname,pr ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc pr_${EXP}_${YEAR}${MON}0100.nc
    	cdo selname,tas ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc tas_${EXP}_${YEAR}${MON}0100.nc
    	cdo selname,tasmax ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc tasmax_${EXP}_${YEAR}${MON}0100.nc
    	cdo selname,tasmin ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc tasmin_${EXP}_${YEAR}${MON}0100.nc
    	cdo selname,clt ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc clt_${EXP}_${YEAR}${MON}0100.nc
    	    
    done
done	

echo 
echo "2. Concatenate data"

cdo cat pr_${EXP}_*0100.nc pr_${EXP}_${DT}.nc 
cdo cat tas_${EXP}_*0100.nc tas_${EXP}_${DT}.nc 
cdo cat tasmax_${EXP}_*0100.nc tasmax_${EXP}_${DT}.nc 
cdo cat tasmin_${EXP}_*0100.nc tasmin_${EXP}_${DT}.nc 
cdo cat clt_${EXP}_*0100.nc clt_${EXP}_${DT}.nc 

echo 
echo "3. Convert unit"

cdo mulc,86400 pr_${EXP}_${DT}.nc pr_${EXP}_RegCM5_day_${DT}.nc
cdo subc,273.15 tas_${EXP}_${DT}.nc tas_${EXP}_RegCM5_day_${DT}.nc
cdo subc,273.15 tasmax_${EXP}_${DT}.nc tasmax_${EXP}_RegCM5_day_${DT}.nc
cdo subc,273.15 tasmin_${EXP}_${DT}.nc tasmin_${EXP}_RegCM5_day_${DT}.nc

echo 
echo "4. Calculate monthly avg"

cdo monmean pr_${EXP}_RegCM5_day_${DT}.nc pr_${EXP}_RegCM5_mon_${DT}.nc
cdo monmean tas_${EXP}_RegCM5_day_${DT}.nc tas_${EXP}_RegCM5_mon_${DT}.nc
cdo monmean tasmax_${EXP}_RegCM5_day_${DT}.nc tasmax_${EXP}_RegCM5_mon_${DT}.nc
cdo monmean tasmin_${EXP}_RegCM5_day_${DT}.nc tasmin_${EXP}_RegCM5_mon_${DT}.nc
cdo monmean clt_${EXP}_${DT}.nc clt_${EXP}_RegCM5_mon_${DT}.nc

echo 
echo "5. Regrid output"

${BIN}/./regrid pr_${EXP}_RegCM5_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid pr_${EXP}_RegCM5_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid tas_${EXP}_RegCM5_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid tasmax_${EXP}_RegCM5_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid tasmin_${EXP}_RegCM5_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid clt_${EXP}_RegCM5_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo 
echo "6. Delete files"

rm *_${DT}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"
