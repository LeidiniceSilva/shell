#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '05/26/2018'
#__description__ = 'Posprocessing the RegCM4.6.0 model data with CDO'
 

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"


SIM='exp2'
DIR="/vol3/disco1/nice/data_file/regcm_data/exp_pbl/output_exp2"

echo
cd ${DIR}
echo ${DIR}

echo 
echo "1. Select variable (PR and T2M)"

for YEAR in `seq -w 2001 2010`; do
    for MON in `seq -w 01 12`; do

        echo "Data: ${YEAR}${MON} - Variable: Precipitation"
        cdo selname,pr amz_neb_STS.${YEAR}${MON}0100.nc pre_flux_amz_neb_regcm_${SIM}_${YEAR}${MON}0100.nc

        echo "Data: ${YEAR}${MON} - Variable: Mean temperature 2 m"
        cdo selname,tas amz_neb_STS.${YEAR}${MON}0100.nc t2m_kelv_amz_neb_regcm_${SIM}_${YEAR}${MON}0100.nc

    done
done	


echo 
echo "2. Concatenate data (2001 - 2010)"

cdo cat pre_flux_amz_neb_regcm_${SIM}_*0100.nc pre_flux_amz_neb_regcm_${SIM}_2001-2010.nc
cdo cat t2m_kelv_amz_neb_regcm_${SIM}_*0100.nc t2m_kelv_amz_neb_regcm_${SIM}_2001-2010.nc


echo 
echo "3. Unit convention (mm and celsius)"

cdo mulc,86400 pre_flux_amz_neb_regcm_${SIM}_2001-2010.nc pre_amz_neb_regcm_${SIM}_2001-2010.nc
cdo addc,-273.15 t2m_kelv_amz_neb_regcm_${SIM}_2001-2010.nc t2m_amz_neb_regcm_${SIM}_2001-2010.nc


echo 
echo "4. Remapbil (Precipitation and Temperature 2m: r720x360)"

cdo remapbil,r720x360 pre_amz_neb_regcm_${SIM}_2001-2010.nc pre_amz_neb_regcm_${SIM}_2001-2010_newgrid.nc
cdo remapbil,r720x360 t2m_amz_neb_regcm_${SIM}_2001-2010.nc t2m_amz_neb_regcm_${SIM}_2001-2010_newgrid.nc 


echo 
echo "5. Sellonlatbox (Precipitation and Temperature 2m: -85,-15,-20,10)"

cdo sellonlatbox,-85,-15,-20,10 pre_amz_neb_regcm_${SIM}_2001-2010_newgrid.nc pre_amz_neb_regcm_${SIM}_2001-2010_newarea.nc
cdo sellonlatbox,-85,-15,-20,10 t2m_amz_neb_regcm_${SIM}_2001-2010_newgrid.nc t2m_amz_neb_regcm_${SIM}_2001-2010_newarea.nc 


echo 
echo "6. Variable: pre e t2m - Statistics index (mean and sum)"

cdo monmean pre_amz_neb_regcm_${SIM}_2001-2010_newarea.nc pre_amz_neb_regcm_${SIM}_mon_2001-2010.nc
cdo monmean t2m_amz_neb_regcm_${SIM}_2001-2010_newarea.nc t2m_amz_neb_regcm_${SIM}_mon_2001-2010.nc


echo 
echo "7. Deleted files"

rm pre_flux_*.nc
rm t2m_kelv_*.nc
rm pre_amz_neb_regcm_${SIM}_2001-2010.nc
rm t2m_amz_neb_regcm_${SIM}_2001-2010.nc
rm pre_amz_neb_regcm_${SIM}_2001-2010_newgrid.nc
rm t2m_amz_neb_regcm_${SIM}_2001-2010_newgrid.nc
rm pre_amz_neb_regcm_${SIM}_2001-2010_newarea.nc
rm t2m_amz_neb_regcm_${SIM}_2001-2010_newarea.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

