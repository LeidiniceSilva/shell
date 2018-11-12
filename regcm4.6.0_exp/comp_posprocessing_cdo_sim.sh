#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '05/26/18'
#__description__ = 'Preprocessing the RegCM4.6.0 model data with CDO'
 

echo
echo "--------------- INIT PREPROCESSING MODEL ----------------"


SIM='bats_exp6'
DIR='/vol3/disco1/nice/PNT_2018/output_exp6/BATS/'

echo
cd ${DIR}
echo ${DIR}


echo 
echo "1. Select variable (PR and T2M)"

for YEAR in 2012; do
    for MON in `seq -w 01 11`; do

        echo "Data: ${YEAR}${MON} - Variable: Precipitation"
        cdo selname,pr amz_neb_exp6_STS.${YEAR}${MON}0100.nc pre_flux_amz_neb_regcm_${SIM}_${YEAR}${MON}0100.nc

        echo "Data: ${YEAR}${MON} - Variable: Mean temperature 2 m"
        cdo selname,tas amz_neb_exp6_SRF.${YEAR}${MON}0100.nc t2m_kelv_amz_neb_regcm_${SIM}_${YEAR}${MON}0100.nc

    done
done	


cdo selname,pr amz_neb_exp6_STS.2011120100.nc pre_flux_amz_neb_regcm_${SIM}_2011.nc
cdo selname,tas amz_neb_exp6_SRF.2011120100.nc t2m_kelv_amz_neb_regcm_${SIM}_2011.nc


echo 
echo "2. Concatenate data (2012)"

cdo cat pre_flux_amz_neb_regcm_${SIM}_*0100.nc pre_flux_amz_neb_regcm_${SIM}_2012.nc
cdo cat t2m_kelv_amz_neb_regcm_${SIM}_*0100.nc t2m_kelv_amz_neb_regcm_${SIM}_2012.nc


echo 
echo "3. Unit convention (mm and celsius)"


cdo mulc,86400 pre_flux_amz_neb_regcm_${SIM}_2012.nc pre_amz_neb_regcm_${SIM}_2012.nc
cdo addc,-273.15 t2m_kelv_amz_neb_regcm_${SIM}_2012.nc t2m_amz_neb_regcm_${SIM}_2012.nc

cdo mulc,86400 pre_flux_amz_neb_regcm_${SIM}_2011.nc pre_amz_neb_regcm_${SIM}_2011.nc
cdo addc,-273.15 t2m_kelv_amz_neb_regcm_${SIM}_2011.nc t2m_amz_neb_regcm_${SIM}_2011.nc


echo 
echo "4. Remapbil (Precipitation and Temperature 2m: r720x360)"

cdo remapbil,r720x360 pre_amz_neb_regcm_${SIM}_2012.nc pre_amz_neb_regcm_${SIM}_2012_newgrid.nc
cdo remapbil,r720x360 t2m_amz_neb_regcm_${SIM}_2012.nc t2m_amz_neb_regcm_${SIM}_2012_newgrid.nc 

cdo remapbil,r720x360 pre_amz_neb_regcm_${SIM}_2011.nc pre_amz_neb_regcm_${SIM}_2011_newgrid.nc
cdo remapbil,r720x360 t2m_amz_neb_regcm_${SIM}_2011.nc t2m_amz_neb_regcm_${SIM}_2011_newgrid.nc 

echo 
echo "5. Sellonlatbox (Precipitation and Temperature 2m: -85,-15,-20,10)"

cdo sellonlatbox,-85,-15,-20,10 pre_amz_neb_regcm_${SIM}_2012_newgrid.nc pre_amz_neb_regcm_${SIM}_2012_newarea.nc
cdo sellonlatbox,-85,-15,-20,10 t2m_amz_neb_regcm_${SIM}_2012_newgrid.nc t2m_amz_neb_regcm_${SIM}_2012_newarea.nc 

cdo sellonlatbox,-85,-15,-20,10 pre_amz_neb_regcm_${SIM}_2011_newgrid.nc pre_amz_neb_regcm_${SIM}_2011_newarea.nc
cdo sellonlatbox,-85,-15,-20,10 t2m_amz_neb_regcm_${SIM}_2011_newgrid.nc t2m_amz_neb_regcm_${SIM}_2011_newarea.nc 


echo 
echo "6. Variable: pre e t2m - Statistics index (mean and sum)"


cdo monmean pre_amz_neb_regcm_${SIM}_2012_newarea.nc pre_amz_neb_regcm_${SIM}_2012_monmean.nc
cdo monmean t2m_amz_neb_regcm_${SIM}_2012_newarea.nc t2m_amz_neb_regcm_${SIM}_2012_monmean.nc

cdo monmean pre_amz_neb_regcm_${SIM}_2011_newarea.nc pre_amz_neb_regcm_${SIM}_2011_monmean.nc
cdo monmean t2m_amz_neb_regcm_${SIM}_2011_newarea.nc t2m_amz_neb_regcm_${SIM}_2011_monmean.nc


echo 
echo "7. Deleted files"

rm pre_flux_amz_neb_regcm_${SIM}_2012*00.nc
rm t2m_kelv_amz_neb_regcm_${SIM}_2012*00.nc
rm pre_flux_amz_neb_regcm_${SIM}_2012.nc
rm t2m_kelv_amz_neb_regcm_${SIM}_2012.nc
rm pre_flux_amz_neb_regcm_${SIM}_2011.nc
rm t2m_kelv_amz_neb_regcm_${SIM}_2011.nc


echo
echo "--------------- THE END PREPROCESSING MODEL ----------------"

