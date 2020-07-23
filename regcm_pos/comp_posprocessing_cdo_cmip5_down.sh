#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '07/21/20'
#__description__ = 'Posprocessing the experiment RegCM4.7 with CDO (Hist and RCP)'
 

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"


SIM="hist"
DIR="/vol1/nice/exp_downscaling/historical/output"

echo
cd ${DIR}
echo ${DIR}


echo 
echo "1. Select variable (PR and T2M)"
for YEAR in `seq -w 1985 2005`; do
    for MON in `seq -w 01 12`; do

        echo "Data: ${YEAR}${MON} - Variable: Precipitation"
        cdo selname,pr reg_${SIM}_STS.${YEAR}${MON}0100.nc pre_flux_amz_neb_regcm_${SIM}_${YEAR}${MON}0100.nc

        echo "Data: ${YEAR}${MON} - Variable: Mean temperature 2 m"
        cdo selname,tas reg_${SIM}_STS.${YEAR}${MON}0100.nc t2m_kelv_amz_neb_regcm_${SIM}_${YEAR}${MON}0100.nc

    done
done	


echo 
echo "2. Concatenate data (1985 - 2005)"
cdo cat pre_flux_amz_neb_regcm_${SIM}_*0100.nc pre_flux_amz_neb_regcm_${SIM}_1985-2005.nc
cdo cat t2m_kelv_amz_neb_regcm_${SIM}_*0100.nc t2m_kelv_amz_neb_regcm_${SIM}_1985-2005.nc


echo 
echo "3. Unit convention (mm and celsius)"
cdo mulc,86400 pre_flux_amz_neb_regcm_${SIM}_2001-2010.nc pre_amz_neb_regcm_${SIM}_1985-2005.nc
cdo addc,-273.15 t2m_kelv_amz_neb_regcm_${SIM}_2001-2010.nc t2m_amz_neb_regcm_${SIM}_1985-2005.nc


echo 
echo "4. Standard calendar (mm and celsius)"
cdo setcalendar,standard pre_amz_neb_regcm_${SIM}_1985-2005.nc pre_amz_neb_regcm_${SIM}_1985-2005_standard.nc
cdo setcalendar,standard t2m_amz_neb_regcm_${SIM}_1985-2005.nc t2m_amz_neb_regcm_${SIM}_1985-2005_standard.nc


echo 
echo "5. Remapbil (Precipitation and Temperature 2m: r720x360)"
cdo remapbil,r1440x720 pre_amz_neb_regcm_${SIM}_1985-2005_standard.nc pre_amz_neb_regcm_${SIM}_1985-2005_newgrid.nc
cdo remapbil,r1440x720 t2m_amz_neb_regcm_${SIM}_1985-2005_standard.nc t2m_amz_neb_regcm_${SIM}_1985-2005_newgrid.nc 


echo 
echo "6. Sellonlatbox (Precipitation and Temperature 2m: -85,-15,-20,10)"
cdo sellonlatbox,-85,-15,-20,10 pre_amz_neb_regcm_${SIM}_1985-2005_newgrid.nc pre_amz_neb_regcm_${SIM}_1985-2005_newarea.nc
cdo sellonlatbox,-85,-15,-20,10 t2m_amz_neb_regcm_${SIM}_1985-2005_newgrid.nc t2m_amz_neb_regcm_${SIM}_1985-2005_newarea.nc 


echo 
echo "7. Variable: pre e t2m - Statistics index (mean and sum)"
cdo monmean pre_amz_neb_regcm_${SIM}_1985-2005_newarea.nc pre_amz_neb_regcm_${SIM}_mon_1985-2005.nc
cdo monmean t2m_amz_neb_regcm_${SIM}_1985-2005_newarea.nc t2m_amz_neb_regcm_${SIM}_mon_1985-2005.nc


echo 
echo "8. Deleted files"
rm pre_flux_*.nc
rm t2m_kelv_*.nc
rm pre_amz_neb_regcm_${SIM}_1985-2005.nc
rm t2m_amz_neb_regcm_${SIM}_1985-2005.nc
rm pre_amz_neb_regcm_${SIM}_1985-2005_standard.nc
rm pre_amz_neb_regcm_${SIM}_1985-2005_standard.nc
rm pre_amz_neb_regcm_${SIM}_1985-2005_newgrid.nc
rm t2m_amz_neb_regcm_${SIM}_1985-2005_newgrid.nc
rm pre_amz_neb_regcm_${SIM}_1985-2005_newarea.nc
rm t2m_amz_neb_regcm_${SIM}_1985-2005_newarea.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

