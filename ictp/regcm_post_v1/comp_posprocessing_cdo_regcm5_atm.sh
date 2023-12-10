#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

EXP="SAM-3km"

DT="2018-2021"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/sam_3km/NoTo-SAM/pressure"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/sam_3km/postproc"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo 
echo "1. Select variable"

for YEAR in `seq -w 2018 2018`; do
    for MON in `seq -w 01 12`; do

    	cdo selname,cli ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100_pressure.nc cli_${EXP}_${YEAR}${MON}0100.nc
    	cdo selname,clw ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100_pressure.nc clw_${EXP}_${YEAR}${MON}0100.nc
    	cdo selname,hus ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100_pressure.nc hus_${EXP}_${YEAR}${MON}0100.nc
    	cdo selname,ua ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100_pressure.nc ua_${EXP}_${YEAR}${MON}0100.nc
    	cdo selname,va ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100_pressure.nc va_${EXP}_${YEAR}${MON}0100.nc
    	cdo selname,cl ${DIR_IN}/${EXP}_RAD.${YEAR}${MON}0100_pressure.nc cl_${EXP}_${YEAR}${MON}0100.nc
    	    
    done
done	

echo 
echo "2. Concatenate data"

cdo cat cli_${EXP}_*0100.nc cli_${EXP}_${DT}.nc 
cdo cat clw_${EXP}_*0100.nc clw_${EXP}_${DT}.nc 
cdo cat hus_${EXP}_*0100.nc hus_${EXP}_${DT}.nc 
cdo cat ua_${EXP}_*0100.nc ua_${EXP}_${DT}.nc 
cdo cat va_${EXP}_*0100.nc va_${EXP}_${DT}.nc 
cdo cat cl_${EXP}_*0100.nc cl_${EXP}_${DT}.nc 

echo 
echo "3. Calculate monthly avg"

cdo monmean cli_${EXP}_${DT}.nc cli_${EXP}_RegCM5_mon_${DT}.nc
cdo monmean clw_${EXP}_${DT}.nc clw_${EXP}_RegCM5_mon_${DT}.nc
cdo monmean hus_${EXP}_${DT}.nc hus_${EXP}_RegCM5_mon_${DT}.nc
cdo monmean ua_${EXP}_${DT}.nc ua_${EXP}_RegCM5_mon_${DT}.nc
cdo monmean va_${EXP}_${DT}.nc va_${EXP}_RegCM5_mon_${DT}.nc
cdo monmean cl_${EXP}_${DT}.nc cl_${EXP}_RegCM5_mon_${DT}.nc

echo 
echo "4. Regrid output"

${BIN}/./regrid cli_${EXP}_RegCM5_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid clw_${EXP}_RegCM5_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid hus_${EXP}_RegCM5_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid ua_${EXP}_RegCM5_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid va_${EXP}_RegCM5_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid cl_${EXP}_RegCM5_mon_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo 
echo "5. Delete files"

#rm *_${EXP}_*0100.nc
#rm *_${EXP}_${DT}.nc
#rm *_${EXP}_RegCM5_mon_${DT}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"
