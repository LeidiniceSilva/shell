#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '12/28/2020'
#__description__ = 'Posprocessing the RegCM4.7.1 model data with CDO'
 

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"


EXP="hist"
DATA="1985-2005"
DIR="/home/nice/Documents/exp_downscaling/hist"

echo
cd ${DIR}
echo ${DIR}

echo 
echo "1. Select variable (PR and TAS)"

for YEAR in `seq -w 1985 2005`; do
    for MON in `seq -w 01 12`; do

        echo "Data: ${YEAR}${MON} - Variable: Precipitation"
        cdo selname,pr reg_${EXP}_STS.${YEAR}${MON}0100.nc pr_flux_reg_had_${EXP}_${YEAR}${MON}0100.nc

        echo "Data: ${YEAR}${MON} - Variable: Mean temperature 2 m"
        cdo selname,tas reg_${EXP}_STS.${YEAR}${MON}0100.nc tas_kelv_reg_had_${EXP}_${YEAR}${MON}0100.nc

    done
done	

echo 
echo "2. Concatenate data (1985 - 2005)"

cdo cat pr_flux_reg_had_${EXP}_*0100.nc pr_flux_reg_had_${EXP}_${DATA}.nc
cdo cat tas_kelv_reg_had_${EXP}_*0100.nc tas_kelv_reg_had_${EXP}_${DATA}.nc

echo
echo "3. Convert calendar: standard"
cdo setcalendar,standard pr_flux_reg_had_${EXP}_${DATA}.nc pr_flux_reg_had_${EXP}_${DATA}_stand.nc
cdo setcalendar,standard tas_kelv_reg_had_${EXP}_${DATA}.nc tas_kelv_reg_had_${EXP}_${DATA}_stand.nc

echo 
echo "4. Unit convention (mm/d and celsius)"

cdo mulc,86400 pr_flux_reg_had_${EXP}_${DATA}_stand.nc pr_reg_had_${EXP}_${DATA}.nc
cdo addc,-273.15 tas_kelv_reg_had_${EXP}_${DATA}_stand.nc tas_reg_had_${EXP}_${DATA}.nc

echo 
echo "5. Remapbil (Precipitation and Temperature 2m: AMZ_NEB)"

./regrid pr_reg_had_${EXP}_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
./regrid tas_reg_had_${EXP}_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil 


echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

