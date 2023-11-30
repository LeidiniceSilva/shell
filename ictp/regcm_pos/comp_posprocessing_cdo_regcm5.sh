#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

NAME="SAM-3km"
DIR="/marconi/home/userexternal/mdasilva/user/mdasilva/sam_3km/postproc"
BIN="/marconi/home/userexternal/ggiulian/binaries_5.0"

echo
cd ${DIR}
echo ${DIR}

echo 
echo "1. Select variable"

for YEAR in `seq -w 2018 2018`; do
    for MON in `seq -w 01 12`; do

    	cdo selname,pr ${NAME}_STS.${YEAR}${MON}0100.nc pr_${NAME}_${YEAR}${MON}0100.nc
    	cdo selname,tas ${NAME}_STS.${YEAR}${MON}0100.nc tas_${NAME}_${YEAR}${MON}0100.nc
    	cdo selname,tasmax ${NAME}_STS.${YEAR}${MON}0100.nc tasmax_${NAME}_${YEAR}${MON}0100.nc
    	cdo selname,tasmin ${NAME}_STS.${YEAR}${MON}0100.nc tasmin_${NAME}_${YEAR}${MON}0100.nc
    	cdo selname,cl ${NAME}_RAD.${YEAR}${MON}0100.nc cl_${NAME}_${YEAR}${MON}0100.nc
    	cdo selname,clt ${NAME}_SRF.${YEAR}${MON}0100.nc clt_${NAME}_${YEAR}${MON}0100.nc
    	cdo selname,cli ${NAME}_ATM.${YEAR}${MON}0100.nc cli_${NAME}_${YEAR}${MON}0100.nc
    	cdo selname,clw ${NAME}_ATM.${YEAR}${MON}0100.nc clw_${NAME}_${YEAR}${MON}0100.nc
    	cdo selname,hus ${NAME}_ATM.${YEAR}${MON}0100.nc hus_${NAME}_${YEAR}${MON}0100.nc
    	cdo selname,ua ${NAME}_ATM.${YEAR}${MON}0100.nc ua_${NAME}_${YEAR}${MON}0100.nc
    	cdo selname,va ${NAME}_ATM.${YEAR}${MON}0100.nc va_${NAME}_${YEAR}${MON}0100.nc
    
    done
done	

echo 
echo "2. Concatenate data"

cdo cat pr_${NAME}_*0100.nc pr_${NAME}_2018-2021.nc 
cdo cat tas_${NAME}_*0100.nc tas_${NAME}_2018-2021.nc 
cdo cat tasmax_${NAME}_*0100.nc tasmax_${NAME}_2018-2021.nc 
cdo cat tasmin_${NAME}_*0100.nc tasmin_${NAME}_2018-2021.nc 
cdo cat cl_${NAME}_*0100.nc cl_${NAME}_2018-2021.nc
cdo cat clt_${NAME}_*0100.nc clt_${NAME}_2018-2021.nc  
cdo cat cli_${NAME}_*0100.nc cli_${NAME}_2018-2021.nc 
cdo cat clw_${NAME}_*0100.nc clw_${NAME}_2018-2021.nc 
cdo cat hus_${NAME}_*0100.nc hus_${NAME}_2018-2021.nc  
cdo cat ua_${NAME}_*0100.nc ua_${NAME}_2018-2021.nc 
cdo cat va_${NAME}_*0100.nc va_${NAME}_2018-2021.nc 

echo 
echo "3. Convert unit"

cdo mulc,86400 pr_${NAME}_2018-2021.nc pr_${NAME}_RegCM5_day_2018-2021.nc
cdo subc,273.15 tas_${NAME}_2018-2021.nc tas_${NAME}_RegCM5_day_2018-2021.nc
cdo subc,273.15 tasmax_${NAME}_2018-2021.nc tasmax_${NAME}_RegCM5_day_2018-2021.nc
cdo subc,273.15 tasmin_${NAME}_2018-2021.nc tasmin_${NAME}_RegCM5_day_2018-2021.nc

echo 
echo "4. Calculate monthly avg"

cdo monmean pr_${NAME}_RegCM5_day_2018-2021.nc pr_${NAME}_RegCM5_mon_2018-2021.nc
cdo monmean tas_${NAME}_RegCM5_day_2018-2021.nc tas_${NAME}_RegCM5_mon_2018-2021.nc
cdo monmean tasmax_${NAME}_RegCM5_day_2018-2021.nc tasmax_${NAME}_RegCM5_mon_2018-2021.nc
cdo monmean tasmin_${NAME}_RegCM5_day_2018-2021.nc tasmin_${NAME}_RegCM5_mon_2018-2021.nc
cdo monmean cl_${NAME}_2018-2021.nc cl_${NAME}_RegCM5_mon_2018-2021.nc
cdo monmean clt_${NAME}_2018-2021.nc clt_${NAME}_RegCM5_mon_2018-2021.nc  
cdo monmean cli_${NAME}_2018-2021.nc cli_${NAME}_RegCM5_mon_2018-2021.nc
cdo monmean clw_${NAME}_2018-2021.nc clw_${NAME}_RegCM5_mon_2018-2021.nc
cdo monmean hus_${NAME}_2018-2021.nc hus_${NAME}_RegCM5_mon_2018-2021.nc  
cdo monmean ua_${NAME}_2018-2021.nc ua_${NAME}_RegCM5_mon_2018-2021.nc
cdo monmean va_${NAME}_2018-2021.nc va_${NAME}_RegCM5_mon_2018-2021.nc

echo 
echo "5. Regrid output"

${BIN}/./regrid pr_${NAME}_RegCM5_day_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid pr_${NAME}_RegCM5_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid tas_${NAME}_RegCM5_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid tasmax_${NAME}_RegCM5_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid tasmin_${NAME}_RegCM5_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid cl_${NAME}_RegCM5_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid clt_${NAME}_RegCM5_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid cli_${NAME}_RegCM5_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid clw_${NAME}_RegCM5_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid hus_${NAME}_RegCM5_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid ua_${NAME}_RegCM5_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${BIN}/./regrid va_${NAME}_RegCM5_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo 
echo "6. Sigma2 output"

${BIN}/./sigma2pCLM45_SKL hus_${NAME}_RegCM5_mon_2018-2021_lonlat.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"
