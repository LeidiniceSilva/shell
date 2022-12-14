#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '12/12/2022'
#__description__ = 'Posprocessing the RegCM5 output data with CDO'
 
echo
echo "--------------- INIT POSPROCESSING REGCM5 ----------------"

EXP="sam4km-pbl1"
DATA="2018-2019"
DIR="/home/nice/Documentos/FPS_SESA/reg5"

echo
cd ${DIR}
echo ${DIR}

echo 
echo "1. Convert grid: regular"

for YEAR in `seq -w 2018 2019`; do
    for MON in `seq -w 01 12`; do

        echo "Data: pr_${EXP}_SRF.${YEAR}${MON}0100.nc"
        /home/nice/Documentos/github_projects/shell/regcm_pos/./regrid pr_${EXP}_SRF.${YEAR}${MON}0100.nc -40,-10,0.0352 -80,-30,0.0352 bil

    done
done	

echo 
echo "2. Concatenate data"

cdo cat pr_${EXP}_*0100_lonlat.nc pr_${EXP}_${DATA}_lonlat.nc

echo
echo "3. Calculate monthly values"

cdo monavg pr_${EXP}_${DATA}_lonlat.nc pr_${EXP}_mon_${DATA}_lonlat.nc

echo
echo "4. Convert unit: mm/d"

cdo mulc,86400 pr_${EXP}_mon_${DATA}_lonlat.nc pr_${EXP}_mon_mmd_${DATA}_lonlat.nc

echo
echo "4. Convert calendar: standard"

cdo setcalendar,standard pr_${EXP}_mon_mmd_${DATA}_lonlat.nc pr_regcm5_${EXP}_mon_mmd_${DATA}_lonlat.nc

echo
echo "--------------- THE END POSPROCESSING REGCM5 ----------------"
