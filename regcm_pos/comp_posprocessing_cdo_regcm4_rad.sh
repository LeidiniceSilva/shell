#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '08/24/2020'
#__description__ = 'Posprocessing the RegCM4.6.0 model data with CDO'
 

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"


SIM="rttm"
DIR="/home/nice/Documents/choluck/rttm"

echo
cd ${DIR}
echo ${DIR}


echo 
echo "1. Select variable (RSNL and RSNS)"
for YEAR in `seq -w 2014 2014`; do
    for MON in `seq -w 01 12`; do
        echo "Data: ${YEAR}${MON} - Variable: RSNL W/m^2"
        cdo selname,rsnl ${SIM}_SRF.${YEAR}${MON}0100.nc rsnl_${SIM}_${YEAR}${MON}0100.nc
        echo "Data: ${YEAR}${MON} - Variable: RSNS W/m^2"
        cdo selname,rsns ${SIM}_SRF.${YEAR}${MON}0100.nc rsns_${SIM}_${YEAR}${MON}0100.nc
    done
done	


echo 
echo "2. Concatenate data (2014)"
cdo cat rsnl_${SIM}_*0100.nc rsnl_${SIM}_2014.nc
cdo cat rsns_${SIM}_*0100.nc rsns_${SIM}_2014.nc


echo
echo "3. Convert calendar: standard"
cdo setcalendar,standard rsnl_${SIM}_2014.nc rsnl_${SIM}_hourly_2014.nc
cdo setcalendar,standard rsns_${SIM}_2014.nc rsns_${SIM}_hourly_2014.nc


echo 
echo "4. Remapbil (RSNL and RSNS: 25 km)"
/home/nice/Documents/choluck/./regrid rsnl_${SIM}_hourly_2014.nc -18.1847,-1.6042,0.25 -48.9033,-31.0967,0.25 bil
/home/nice/Documents/choluck/./regrid rsns_${SIM}_hourly_2014.nc -18.1847,-1.6042,0.25 -48.9033,-31.0967,0.25 bil


echo 
echo "5. Deleted files"
rm rsnl_${SIM}_*0100.nc
rm rsns_${SIM}_*0100.nc
rm rsnl_${SIM}_2014.nc
rm rsns_${SIM}_2014.nc
rm rsnl_${SIM}_hourly_2014.nc
rm rsns_${SIM}_hourly_2014.nc


echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

