#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '05/26/18'
#__description__ = 'Preprocessing the RegCM4.6.0 model data with CDO'
 

echo
echo "--------------- INIT PREPROCESSING MODEL ----------------"

SIM='exp1'
DIR='/vol3/nice/output1'

echo
cd ${DIR}
echo ${DIR}


echo 
echo "1. Select variable (PR and T2M)"

for YEAR in `seq 2001 2005`; do
    for MON in `seq -w 01 12`; do

        echo "Data: ${YEAR}${MON} - Variable: Precipitation"
        cdo selname,pr amz_neb_STS.${YEAR}${MON}0100.nc pre_amz_neb_regcm_${SIM}_${YEAR}${MON}0100.nc

        echo "Data: ${YEAR}${MON} - Variable: Mean temperature 2 m"
        cdo selname,tas amz_neb_SRF.${YEAR}${MON}0100.nc t2m_amz_neb_regcm_${SIM}_${YEAR}${MON}0100.nc

    done
done	


echo 
echo "2. Concatenate data (2001-2005)"

cdo cat pre_amz_neb_regcm_${SIM}_*0100.nc pre_flux_amz_neb_regcm_${SIM}_2001-2005.nc
cdo cat t2m_amz_neb_regcm_${SIM}_*0100.nc t2m_Kelv_amz_neb_regcm_${SIM}_2001-2005.nc


echo 
echo "3. Unit convention (mm and celsius)"

cdo mulc,86400 pre_flux_amz_neb_regcm_${SIM}_2001-2005.nc pre_amz_neb_regcm_${SIM}_2001-2005.nc
cdo addc,-273.15 t2m_K_amz_neb_regcm_${SIM}_2001-2005.nc t2m_amz_neb_regcm_${SIM}_2001-2005.nc


echo 
echo "4. Remapbil (Precipitation and Temperature 2m: r720x360)"

cdo remapbil,r720x360 pre_amz_neb_regcm_${SIM}_2001-2005.nc pre_amz_neb_regcm_${SIM}_2001-2005_newgrid.nc
cdo remapbil,r720x360 t2m_amz_neb_regcm_${SIM}_2001-2005.nc t2m_amz_neb_regcm_${SIM}_2001-2005_newgrid.nc 


echo 
echo "5. Sellonlatbox (Precipitation and Temperature 2m: -85,-15,-20,10)"

cdo sellonlatbox,-85,-15,-20,10 pre_amz_neb_regcm_${SIM}_2001-2005_newgrid.nc pre_amz_neb_regcm_${SIM}_mon_2001-2005_newarea.nc
cdo sellonlatbox,-85,-15,-20,10 t2m_amz_neb_regcm_${SIM}_2001-2005_newgrid.nc t2m_amz_neb_regcm_${SIM}_mon_2001-2005_newarea.nc 


echo 
echo "6. Variable: ${VAR} - Statistics index (mean and sum)"

for VAR in pre t2m; do

    cdo monsum ${VAR}_amz_neb_regcm_${SIM}_mon_2001-2005.nc ${VAR}_amz_neb_regcm_${SIM}_2001-2005_monsum.nc
    cdo monmean ${VAR}_amz_neb_regcm_${SIM}_mon_2001-2005.nc ${VAR}_amz_neb_regcm_${SIM}_2001-2005_monmean.nc
    cdo yearavg ${VAR}_amz_neb_regcm_${SIM}_mon_2001-2005.nc ${VAR}_amz_neb_regcm_${SIM}_2001-2005_monmean.nc
    cdo ymonmean ${VAR}_amz_neb_regcm_${SIM}_2001-2005_monmean.nc ${VAR}_amz_neb_regcm_${SIM}_2001-2005_clim.nc

done


echo 
echo "7. Deleted files"

rm pre_amz_neb_regcm_${SIM}_*0100.nc
rm t2m_amz_neb_regcm_${SIM}_*0100.nc
rm pre_flux_amz_neb_regcm_${SIM}_2001-2005.nc
rm t2m_K_amz_neb_regcm_${SIM}_2001-2005.nc


echo
echo "--------------- THE END PREPROCESSING MODEL ----------------"

