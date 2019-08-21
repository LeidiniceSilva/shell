#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '05/26/18'
#__description__ = 'Preprocessing the observation data with CDO'
 

echo
echo "--------------- INIT PREPROCESSING OBS ----------------"


DIR="/vol3/disco1/nice/data_file/obs_data"

echo
cd ${DIR}
echo ${DIR}

echo 
echo "1. Select data (Precipitation and Temperature 2m: 2001010100-2010123100)"

cdo seldate,2001-01-00T00:00:00,2010-12-31T00:00:00 tmp_cru_ts4.02_obs_mon_1901-2017.nc tmp_cru_ts4.02_obs_mon_2001-2010.nc


echo 
echo "2. Remapbil (Precipitation and Temperature 2m: r720x360)"

cdo remapbil,r720x360 tmp_cru_ts4.02_obs_mon_2001-2010.nc tmp_cru_ts4.02_obs_mon_2001-2010_newgrid.nc 


echo 
echo "3. Sellonlatbox (Precipitation and Temperature 2m: -85,-15,-20,10)"

cdo sellonlatbox,-85,-15,-20,10 tmp_cru_ts4.02_obs_mon_2001-2010_newgrid.nc tmp_amz_neb_cru_ts4.02_obs_mon_2001-2010.nc


rm tmp_cru_ts4.02_obs_mon_2001-2010.nc
rm tmp_cru_ts4.02_obs_mon_2001-2010_newgrid.nc 

echo
echo "--------------- END PREPROCESSING OBS ----------------"















