#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '07/26/18'
#__description__ = 'Posprocessing the RegCM4.6.0 model data with CDO'
 

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"


DIR='/vol3/claudio/SIM30ANOS1/SRF'
SIM=sim30anos1

echo
cd ${DIR}
echo ${DIR}


echo 
echo "1. Select variable (PRE and T2M)"

for YEAR in `seq 1981 2010`; do
    for MON in `seq -w 01 12`; do

	echo
        echo "Data: ${YEAR}${MON}"
        cdo selname,tpr SRF.${YEAR}${MON}.nc pre_srf_${YEAR}${MON}.nc
        cdo selname,t2m SRF.${YEAR}${MON}.nc t2m_srf_${YEAR}${MON}.nc

    done
done	


echo 
echo "2. Concatenate data (1981-2010)"

cdo cat pre_srf_*.nc pre_mon_${SIM}_1981_2010.nc
cdo cat t2m_srf_*.nc t2m_K_srf_${SIM}_1981_2010.nc


echo 
echo "3. Unit convention (Celsius)"

cdo addc,-273.15 t2m_K_srf_${SIM}_1981_2010.nc t2m_mon_${SIM}_1981_2010.nc


echo 
echo "4. Deleted files"

rm pre_srf_*.nc
rm t2m_srf_*.nc
rm t2m_K_srf_sim30anos1_1981_2010.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

