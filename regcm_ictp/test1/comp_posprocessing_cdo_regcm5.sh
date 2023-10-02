#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '10/02/2023'
#__description__ = 'Posprocessing the RegCM5 model data with CDO'
 

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

NAME="SAM-22"
DIR="/home/mda_silv/scratch/test1/output"

echo
cd ${DIR}
echo ${DIR}

echo 
echo "1. Select variable (precipitation and temperature)"

for MON in `seq -w 01 12`; do

    echo "Data: ${MON} - Variables: Precipitation"
    cdo selname,pr ${NAME}_STS.2000${MON}0100.nc pr_${NAME}_2000${MON}0100.nc
    echo "Data: ${YEAR}${MON} - Variable: Temperature 2 m"
    cdo selname,tas ${NAME}_STS.2000${MON}0100.nc tas_${NAME}_2000${MON}0100.nc
done	

echo 
echo "2. Concatenate data"

echo "Data: ${NAME} - Variables: Precipitation"
cdo cat pr_${NAME}_2000*0100.nc pr_${NAME}_mon_2000.nc 
echo "Data: ${NAME} - Variable: Temperature 2 m"
cdo cat tas_${NAME}_2000*0100.nc tas_${NAME}_mon_2000.nc 

echo
echo "3. Convert calendar: standard"

echo "Data: ${DATA} - Variables: Precipitation"
cdo setcalendar,standard pr_${NAME}_mon_2000.nc pr_${NAME}_mon_2000_calendar.nc
echo "Data: ${DATA} - Variable: Temperature 2 m"
cdo setcalendar,standard tas_${NAME}_mon_2000.nc tas_${NAME}_mon_2000_calendar.nc

echo 
echo "4. Remapbil (Precipitation and Temperature 2m: South America)"

echo "Data: ${DATA} - Variables: Precipitation"
/home/mda_silv/github_projects/shell/regcm_pos/./regrid pr_${NAME}_mon_2000_calendar.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil
echo "Data: ${DATA} - Variable: Temperature 2 m"
/home/mda_silv/github_projects/shell/regcm_pos/./regrid tas_${NAME}_mon_2000_calendar.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil 

echo 
echo "5. Unit convention (mm/d and celsius)"

echo "Data: ${DATA} - Variables: Precipitation"
cdo mulc,86400 pr_${NAME}_mon_2000_calendar_lonlat.nc pr_${NAME}_mon_2000_lonlat.nc
echo "Data: ${DATA} - Variable: Temperature 2 m"
cdo addc,-273.15 tas_${NAME}_mon_2000_calendar_lonlat.nc tas_${NAME}_mon_2000_lonlat.nc


echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"
