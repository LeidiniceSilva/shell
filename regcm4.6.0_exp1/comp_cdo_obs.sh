#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '05/26/18'
#__description__ = 'Preprocessing the observation data with CDO'
 

echo
echo "--------------- INIT PREPROCESSING OBS ----------------"


cd /vol3/nice/obs


echo 
echo "1. Select data (1979010100-2010123100)"

cdo seldate,1979-01-00T00:00:00,2010-12-31T00:00:00 pre_cru_ts4.01_observation_1901-2016.nc pre_cru_ts4.01_observation_1979-2010.nc
cdo seldate,1979-01-00T00:00:00,2010-12-31T00:00:00 t2m_cru_ts4.01_observation_1901-2016.nc t2m_cru_ts4.01_observation_1979-2010.nc

echo 
echo "5. Creating new areas (A1, A2, A3, A4, A5, A6, A7, A8)"


for VAR in pre t2m; do

    echo
    echo "Variable: ${VAR}"

    cdo sellonlatbox,-63,-55,-9,-1 ${VAR}_cru_ts4.01_observation_1979-2010.nc ${VAR}_cru_ts4.01_observation_1979-2010_amz_neb.nc
    cdo sellonlatbox,-63,-55,-9,-1 ${VAR}_cru_ts4.01_observation_1979-2010.nc ${VAR}_cru_ts4.01_observation_1979-2010_A1.nc
    cdo sellonlatbox,-52.5,-45.5,-3.55,3.5 ${VAR}_cru_ts4.01_observation_1979-2010.nc ${VAR}_cru_ts4.01_observation_1979-2010_A2.nc
    cdo sellonlatbox,-75,-71,-15,-11 ${VAR}_cru_ts4.01_observation_1979-2010.nc ${VAR}_cru_ts4.01_observation_1979-2010_A3.nc
    cdo sellonlatbox,-78,-72,0,8 ${VAR}_cru_ts4.01_observation_1979-2010.nc ${VAR}_cru_ts4.01_observation_1979-2010_A4.nc
    cdo sellonlatbox,-73,-65,-10,-3 ${VAR}_cru_ts4.01_observation_1979-2010.nc ${VAR}_cru_ts4.01_observation_1979-2010_A5.nc
    cdo sellonlatbox,-48,-38,-5,-1 ${VAR}_cru_ts4.01_observation_1979-2010.nc ${VAR}_cru_ts4.01_observation_1979-2010_A6.nc
    cdo sellonlatbox,-48,-38,-11,-5 ${VAR}_cru_ts4.01_observation_1979-2010.nc ${VAR}_cru_ts4.01_observation_1979-2010_A7.nc
    cdo sellonlatbox,-38,-34,-11,-5 ${VAR}_cru_ts4.01_observation_1979-2010.nc ${VAR}_cru_ts4.01_observation_1979-2010_A8.nc

done



















