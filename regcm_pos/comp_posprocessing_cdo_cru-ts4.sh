#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '12/28/2020'
#__description__ = 'Preprocessing the observation data with CDO'
 

echo
echo "--------------- INIT PREPROCESSING OBS ----------------"

DIR="/home/nice/Documents/obs_data"

echo
cd ${DIR}
echo ${DIR}

echo 
echo "1. Select data (Precipitation and Temperature 2m: 1986-2005)"

cdo seldate,1986-01-01T00:00:00,2005-12-31T00:00:00 pre_cru_ts4.04_obs_mon_1901-2019.nc pre_cru_ts4.04_obs_mon_1986-2005.nc
cdo seldate,1986-01-01T00:00:00,2005-12-31T00:00:00 tmp_cru_ts4.04_obs_mon_1901-2019.nc tmp_cru_ts4.04_obs_mon_1986-2005.nc

echo 
echo "2. Remapbil (Precipitation and Temperature 2m: AMZ_NEB)"

/home/nice/Documents/github_projects/shell/regcm_pos/./regrid pre_cru_ts4.04_obs_mon_1986-2005.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid tmp_cru_ts4.04_obs_mon_1986-2005.nc -20,10,0.25 -85,-15,0.25 bil

echo 
echo "3. Unit convention (mm/d)"

cdo divc,30.5 pre_cru_ts4.04_obs_mon_1986-2005_lonlat.nc pre_amz_neb_cru_ts4.04_obs_mon_1986-2005_lonlat.nc

echo
echo "4. Select new area: amz (-68,-52,-12,-3), neb (-40,-35,-16,-3) and matopiba (-50.5,-42.5,-15,-2.5)"

cdo sellonlatbox,-68,-52,-12,-3 pre_amz_neb_cru_ts4.04_obs_mon_1986-2005_lonlat.nc pre_samz_cru_ts4.04_obs_mon_1986-2005_lonlat.nc
cdo sellonlatbox,-40,-35,-16,-3 pre_amz_neb_cru_ts4.04_obs_mon_1986-2005_lonlat.nc pre_eneb_cru_ts4.04_obs_mon_1986-2005_lonlat.nc
cdo sellonlatbox,-50.5,-42.5,-15,-2.5 pre_amz_neb_cru_ts4.04_obs_mon_1986-2005_lonlat.nc pre_matopiba_cru_ts4.04_obs_mon_1986-2005_lonlat.nc

cdo sellonlatbox,-68,-52,-12,-3 tmp_amz_neb_cru_ts4.04_obs_mon_1986-2005_lonlat.nc tmp_samz_cru_ts4.04_obs_mon_1986-2005_lonlat.nc
cdo sellonlatbox,-40,-35,-16,-3 tmp_amz_neb_cru_ts4.04_obs_mon_1986-2005_lonlat.nc tmp_eneb_cru_ts4.04_obs_mon_1986-2005_lonlat.nc
cdo sellonlatbox,-50.5,-42.5,-15,-2.5 tmp_amz_neb_cru_ts4.04_obs_mon_1986-2005_lonlat.nc tmp_matopiba_cru_ts4.04_obs_mon_1986-2005_lonlat.nc

echo 
echo "5. Deleting file"

rm pre_cru_ts4.04_obs_mon_1901-2019.nc
rm pre_cru_ts4.04_obs_mon_1986-2005_lonlat.nc
rm tmp_cru_ts4.04_obs_mon_1901-2019.nc
rm tmp_cru_ts4.04_obs_mon_1986-2005_lonlat.nc

echo
echo "--------------- END PREPROCESSING OBS ----------------"















