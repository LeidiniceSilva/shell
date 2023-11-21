#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

NAME="SAM-3km"
DIR="/marconi/home/userexternal/mdasilva/user/mdasilva/sam_3km/output"

echo
cd ${DIR}
echo ${DIR}

echo 
echo "1. Select variable"

for YEAR in `seq -w 2018 2021`; do
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

cdo cat pr_${NAME}_*0100.nc pr_${NAME}_day_2018-2021.nc 
cdo cat tas_${NAME}_*0100.nc tas_${NAME}_day_2018-2021.nc 
cdo cat tasmax_${NAME}_*0100.nc tasmax_${NAME}_day_2018-2021.nc 
cdo cat tasmin_${NAME}_*0100.nc tasmin_${NAME}_day_2018-2021.nc 
cdo cat cl_${NAME}_*0100.nc cl_${NAME}_2018-2021.nc
cdo cat clt_${NAME}_*0100.nc clt_${NAME}_2018-2021.nc  
cdo cat cli_${NAME}_*0100.nc cli_${NAME}_2018-2021.nc 
cdo cat clw_${NAME}_*0100.nc clw_${NAME}_2018-2021.nc 
cdo cat hus_${NAME}_*0100.nc hus_${NAME}_2018-2021.nc  
cdo cat ua_${NAME}_*0100.nc ua_${NAME}_2018-2021.nc 
cdo cat va_${NAME}_*0100.nc va_${NAME}_2018-2021.nc 

echo 
echo "2. Calculate monthly avg"

cdo monmean cl_${NAME}_2018.nc cl_${NAME}_mon_2018-2021.nc
cdo monmean clt_${NAME}_2018.nc clt_${NAME}_mon_2018-2021.nc  
cdo monmean cli_${NAME}_2018.nc cli_${NAME}_mon_2018-2021.nc
cdo monmean clw_${NAME}_2018.nc clw_${NAME}_mon_2018-2021.nc
cdo monmean hus_${NAME}_2018.nc hus_${NAME}_mon_2018-2021.nc  
cdo monmean ua_${NAME}_2018.nc ua_${NAME}_mon_2018-2021.nc
cdo monmean va_${NAME}_2018.nc va_${NAME}_mon_2018-2021.nc

echo 
echo "3. Regrid output"

/marconi/home/userexternal/mdasilva/github_projects/shell/regcm_ufrn/regcm_pos/./regrid pr_${NAME}_day_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
/marconi/home/userexternal/mdasilva/github_projects/shell/regcm_ufrn/regcm_pos/./regrid tas_${NAME}_day_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
/marconi/home/userexternal/mdasilva/github_projects/shell/regcm_ufrn/regcm_pos/./regrid tasmax_${NAME}_day_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
/marconi/home/userexternal/mdasilva/github_projects/shell/regcm_ufrn/regcm_pos/./regrid tasmin_${NAME}_day_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
/marconi/home/userexternal/mdasilva/github_projects/shell/regcm_ufrn/regcm_pos/./regrid cl_${NAME}_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
/marconi/home/userexternal/mdasilva/github_projects/shell/regcm_ufrn/regcm_pos/./regrid clt_${NAME}_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
/marconi/home/userexternal/mdasilva/github_projects/shell/regcm_ufrn/regcm_pos/./regrid cli_${NAME}_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
/marconi/home/userexternal/mdasilva/github_projects/shell/regcm_ufrn/regcm_pos/./regrid clw_${NAME}_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
/marconi/home/userexternal/mdasilva/github_projects/shell/regcm_ufrn/regcm_pos/./regrid hus_${NAME}_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
/marconi/home/userexternal/mdasilva/github_projects/shell/regcm_ufrn/regcm_pos/./regrid ua_${NAME}_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
/marconi/home/userexternal/mdasilva/github_projects/shell/regcm_ufrn/regcm_pos/./regrid va_${NAME}_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil


echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"
