#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '05/26/18'
#__description__ = 'Preprocessing the RegCM4.6.0 model data with CDO'
 

echo
echo "--------------- INIT PREPROCESSING MODEL ----------------"


cd /vol3/nice/output

echo 
echo "1. Selname (PR and T2M)"

for YEAR in `seq 2001 2005`; do
    for MON in `seq -w 1 12`; do
    
        echo "Data: ${YEAR}${MON}"

        cdo selname,pr amz_neb_STS.${YEAR}${MON}0100_prepross.nc pr_amz_neb_regcm_exp1_${YEAR}${MON}0100.nc
        cdo selname,t2m amz_neb_SRF.${YEAR}${MON}0100_prepross.nc t2m_amz_neb_regcm_exp1_${YEAR}${MON}0100.nc

    done
done	


echo 
echo "2. Concatenate (2001-2005)"
	
cdo cat pr_amz_neb_regcm_exp1_*.nc pr_flux_amz_neb_regcm_exp1_2001-2005.nc
cdo cat t2m_amz_neb_regcm_exp1_*.nc t2m_amz_neb_regcm_exp1_2001-2005.nc


echo 
echo "3. Multiplicate for a constant (precipitation flux = mm)"

cdo mulc,86400 pr_flux_amz_neb_regcm_exp1_2001-2005.nc pr_amz_neb_regcm_exp1_2001-2005.nc


echo 
echo "4. sellonlatbox (A1, A2, A3, A4, A5, A6, A7, A8)"

for VAR in pr t2m; do

    echo "Variable: ${YEAR}"
	
    cdo sellonlatbox,30,60,-6,-50 pr_amz_neb_regcm_exp1_2001-2005.nc pr_amz_neb_regcm_exp1_2001-2005_A1.nc
    cdo sellonlatbox,30,60,-6,-50 pr_amz_neb_regcm_exp1_2001-2005.nc pr_amz_neb_regcm_exp1_2001-2005_A2.nc
    cdo sellonlatbox,30,60,-6,-50 pr_amz_neb_regcm_exp1_2001-2005.nc pr_amz_neb_regcm_exp1_2001-2005_A3.nc
    cdo sellonlatbox,30,60,-6,-50 pr_amz_neb_regcm_exp1_2001-2005.nc pr_amz_neb_regcm_exp1_2001-2005_A4.nc
    cdo sellonlatbox,30,60,-6,-50 pr_amz_neb_regcm_exp1_2001-2005.nc pr_amz_neb_regcm_exp1_2001-2005_A5.nc
    cdo sellonlatbox,30,60,-6,-50 pr_amz_neb_regcm_exp1_2001-2005.nc pr_amz_neb_regcm_exp1_2001-2005_A6.nc
    cdo sellonlatbox,30,60,-6,-50 pr_amz_neb_regcm_exp1_2001-2005.nc pr_amz_neb_regcm_exp1_2001-2005_A7.nc
    cdo sellonlatbox,30,60,-6,-50 pr_amz_neb_regcm_exp1_2001-2005.nc pr_amz_neb_regcm_exp1_2001-2005_A8.nc

done

echo
echo "--------------- THE END PREPROCESSING MODEL ----------------"





cdo seldate,1979-01-00T00:00:00,2010-12-31T00:00:00 pre_cru_ts4.01_observation_1901-2016.nc pre_cru_ts4.01_observation_1979-2010.nc
cdo seldate,1979-01-00T00:00:00,2010-12-31T00:00:00 t2m_cru_ts4.01_observation_1901-2016.nc tmp_cru_ts4.01_observation_1979-2010.nc

cdo remapbil,pre_cru_ts4.01_observation_1979-2010.nc pr_amz_neb_regcm_exp1_2001-2005.nc pr_amz_neb_regcm_exp1_int_2001-2005.nc
cdo remapbil,tmp_cru_ts4.01_observation_1979-2010.nc t2m_amz_neb_regcm_exp1_2001-2005.nc t2m_amz_neb_regcm_exp1_int_2001-2005.nc

cdo sellonlatbox,30,60,-6,-50 pre_cru_ts4.01_observation_1979-2010.nc pre_amz_neb_cru_ts4.01_observation_1979-2010_A1.nc
cdo sellonlatbox,30,60,-6,-50 pre_cru_ts4.01_observation_1979-2010.nc pre_amz_neb_cru_ts4.01_observation_1979-2010_A2.nc
cdo sellonlatbox,30,60,-6,-50 pre_cru_ts4.01_observation_1979-2010.nc pre_amz_neb_cru_ts4.01_observation_1979-2010_A3.nc
cdo sellonlatbox,30,60,-6,-50 pre_cru_ts4.01_observation_1979-2010.nc pre_amz_neb_cru_ts4.01_observation_1979-2010_A4.nc
cdo sellonlatbox,30,60,-6,-50 pre_cru_ts4.01_observation_1979-2010.nc pre_amz_neb_cru_ts4.01_observation_1979-2010_A5.nc
cdo sellonlatbox,30,60,-6,-50 pre_cru_ts4.01_observation_1979-2010.nc pre_amz_neb_cru_ts4.01_observation_1979-2010_A6.nc
cdo sellonlatbox,30,60,-6,-50 pre_cru_ts4.01_observation_1979-2010.nc pre_amz_neb_cru_ts4.01_observation_1979-2010_A7.nc
cdo sellonlatbox,30,60,-6,-50 pre_cru_ts4.01_observation_1979-2010.nc pre_amz_neb_cru_ts4.01_observation_1979-2010_A8.nc

cdo sellonlatbox,30,60,-6,-50 tmp_cru_ts4.01_observation_1979-2010.nc tmp_amz_neb_cru_ts4.01_observation_1979-2010_A1.nc
cdo sellonlatbox,30,60,-6,-50 tmp_cru_ts4.01_observation_1979-2010.nc tmp_amz_neb_cru_ts4.01_observation_1979-2010_A2.nc
cdo sellonlatbox,30,60,-6,-50 tmp_cru_ts4.01_observation_1979-2010.nc tmp_amz_neb_cru_ts4.01_observation_1979-2010_A3.nc
cdo sellonlatbox,30,60,-6,-50 tmp_cru_ts4.01_observation_1979-2010.nc tmp_amz_neb_cru_ts4.01_observation_1979-2010_A4.nc
cdo sellonlatbox,30,60,-6,-50 tmp_cru_ts4.01_observation_1979-2010.nc tmp_amz_neb_cru_ts4.01_observation_1979-2010_A5.nc
cdo sellonlatbox,30,60,-6,-50 tmp_cru_ts4.01_observation_1979-2010.nc tmp_amz_neb_cru_ts4.01_observation_1979-2010_A6.nc
cdo sellonlatbox,30,60,-6,-50 tmp_cru_ts4.01_observation_1979-2010.nc tmp_amz_neb_cru_ts4.01_observation_1979-2010_A7.nc
cdo sellonlatbox,30,60,-6,-50 tmp_cru_ts4.01_observation_1979-2010.nc tmp_amz_neb_cru_ts4.01_observation_1979-2010_A8.nc

















