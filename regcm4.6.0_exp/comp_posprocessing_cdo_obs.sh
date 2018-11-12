#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '05/26/18'
#__description__ = 'Preprocessing the observation data with CDO'
 

echo
echo "--------------- INIT PREPROCESSING OBS ----------------"


cd /vol3/nice/obs


echo 
echo "1. Select data (Precipitation and Temperature 2m: 2001010100-2005123100)"

cdo seldate,2001-01-00T00:00:00,2005-12-31T00:00:00 pre_mon_cmap_observation_1979-2018.nc pre_mon_cmap_observation_2001-2005.nc
cdo seldate,2001-01-00T00:00:00,2005-12-31T00:00:00 t2m_mon_ncep_ncar_reanalysis_1948-2018.nc t2m_mon_ncep_ncar_reanalysis_2001-2005.nc


echo 
echo "2. Remapbil (Precipitation and Temperature 2m: r720x360)"

cdo remapbil,r720x360 pre_mon_cmap_observation_2001-2005.nc pre_mon_cmap_observation_2001-2005_newgrid.nc 
cdo remapbil,r720x360 t2m_mon_ncep_ncar_reanalysis_2001-2005.nc t2m_mon_ncep_ncar_reanalysis_2001-2005_newgrid.nc 


echo 
echo "3. Sellonlatbox (Precipitation and Temperature 2m: -85,-15,-20,10)"

cdo sellonlatbox,-85,-15,-20,10 pre_mon_cmap_observation_2001-2005_newgrid.nc pre_amz_neb_cmap_observation_mon_2001-2005.nc 
cdo sellonlatbox,-85,-15,-20,10 t2m_mon_ncep_ncar_reanalysis_2001-2005_newgrid.nc t2m_amz_neb_ncep_ncar_reanalysis_mon_2001-2005.nc 


echo 
echo "4. Statistics index (Precipitation and Temperature 2m: mean, sum and clim)"

cdo monsum pre_amz_neb_cmap_observation_mon_2001-2005.nc pre_amz_neb_cmap_observation_2001-2005_monsum.nc 
cdo monmean pre_amz_neb_cmap_observation_mon_2001-2005.nc pre_amz_neb_cmap_observation_2001-2005_monmean.nc
cdo ymonmean pre_amz_neb_cmap_observation_mon_2001-2005_monmean.nc pre_amz_neb_cmap_observation_2001-2005_clim.nc

cdo monsum t2m_amz_neb_ncep_ncar_reanalysis_mon_2001-2005.nc t2m_amz_neb_ncep_ncar_reanalysis_2001-2005_monsum.nc 
cdo monmean t2m_amz_neb_ncep_ncar_reanalysis_mon_2001-2005.nc t2m_amz_neb_ncep_ncar_reanalysis_2001-2005_monmean.nc 
cdo ymonmean 2m_amz_neb_ncep_ncar_reanalysis_mon_2001-2005_monmean.nc 2m_amz_neb_ncep_ncar_reanalysis_2001-2005_clim.nc 


echo
echo "--------------- END PREPROCESSING OBS ----------------"















