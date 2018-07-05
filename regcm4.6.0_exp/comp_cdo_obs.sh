#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '05/26/18'
#__description__ = 'Preprocessing the observation data with CDO'
 

echo
echo "--------------- INIT PREPROCESSING OBS ----------------"


cd /vol3/nice/obs


echo 
echo "1. Select data (1981010100-2010123100 / 2001010100-2005123100)"

echo
echo "Precipitation"
cdo seldate,1981-01-00T00:00:00,2010-12-31T00:00:00 pre_mon_cmap_observation_1979-2018.nc pre_mon_cmap_observation_1981-2010.nc
cdo seldate,2001-01-00T00:00:00,2005-12-31T00:00:00 pre_mon_cmap_observation_1979-2018.nc pre_mon_cmap_observation_2001-2005.nc

echo
echo "Temperature 2m"
cdo seldate,1981-01-00T00:00:00,2010-12-31T00:00:00 t2m_mon_ncep_ncar_reanalysis_1948-2018.nc t2m_mon_ncep_ncar_reanalysis_1981-2010.nc
cdo seldate,2001-01-00T00:00:00,2005-12-31T00:00:00 t2m_mon_ncep_ncar_reanalysis_1948-2018.nc t2m_mon_ncep_ncar_reanalysis_2001-2005.nc


echo 
echo "2. Creating new areas (A0, A1, A2, A3, A4, A5, A6, A7, A8)"

echo
echo "Precipitation"
cdo sellonlatbox,-85.27,-14.65,-22.59,11 pre_mon_cmap_observation_2001-2005.nc pre_amz_neb_cmap_observation_2001-2005_A0.nc
cdo sellonlatbox,-63,-55,-9,-1 pre_mon_cmap_observation_2001-2005.nc pre_amz_neb_cmap_observation_2001-2005_A1.nc
cdo sellonlatbox,-53.5,-47.5,-3.55,3.5 pre_mon_cmap_observation_2001-2005.nc pre_amz_neb_cmap_observation_2001-2005_A2.nc
cdo sellonlatbox,-75,-71,-15,-11 pre_mon_cmap_observation_2001-2005.nc pre_amz_neb_cmap_observation_2001-2005_A3.nc
cdo sellonlatbox,-70,-66,-1,3 pre_mon_cmap_observation_2001-2005.nc pre_amz_neb_cmap_observation_2001-2005_A4.nc
cdo sellonlatbox,-73,-65,-10,-3 pre_mon_cmap_observation_2001-2005.nc pre_amz_neb_cmap_observation_2001-2005_A5.nc
cdo sellonlatbox,-47,-38,-5.5,-1 pre_mon_cmap_observation_2001-2005.nc pre_amz_neb_cmap_observation_2001-2005_A6.nc
cdo sellonlatbox,-48,-38,-11,-6 pre_mon_cmap_observation_2001-2005.nc pre_amz_neb_cmap_observation_2001-2005_A7.nc
cdo sellonlatbox,-37.5,-34,-11,-5 pre_mon_cmap_observation_2001-2005.nc pre_amz_neb_cmap_observation_2001-2005_A8.nc

echo
echo "Temperature 2m"
cdo sellonlatbox,-85.27,-14.65,-22.59,11 t2m_mon_ncep_ncar_reanalysis_2001-2005.nc t2m_amz_neb_ncep_ncar_reanalysis_2001-2005_A0.nc
cdo sellonlatbox,-63,-55,-9,-1 t2m_mon_ncep_ncar_reanalysis_2001-2005.nc t2m_amz_neb_ncep_ncar_reanalysis_2001-2005_A1.nc
cdo sellonlatbox,-53.5,-47.5,-3.55,3.5 t2m_mon_ncep_ncar_reanalysis_2001-2005.nc t2m_amz_neb_ncep_ncar_reanalysis_2001-2005_A2.nc
cdo sellonlatbox,-75,-71,-15,-11 t2m_mon_ncep_ncar_reanalysis_2001-2005.nc t2m_amz_neb_ncep_ncar_reanalysis_2001-2005_A3.nc
cdo sellonlatbox,-70,-66,1,3 t2m_mon_ncep_ncar_reanalysis_2001-2005.nc t2m_amz_neb_ncep_ncar_reanalysis_2001-2005_A4.nc
cdo sellonlatbox,-73,-65,-10,-3 t2m_mon_ncep_ncar_reanalysis_2001-2005.nc t2m_amz_neb_ncep_ncar_reanalysis_2001-2005_A5.nc
cdo sellonlatbox,-47,-38,-5.5,-1 t2m_mon_ncep_ncar_reanalysis_2001-2005.nc t2m_amz_neb_ncep_ncar_reanalysis_2001-2005_A6.nc
cdo sellonlatbox,-48,-38,-11,-6 t2m_mon_ncep_ncar_reanalysis_2001-2005.nc t2m_amz_neb_ncep_ncar_reanalysis_2001-2005_A7.nc
cdo sellonlatbox,-37.5,-34,-11,-5 t2m_mon_ncep_ncar_reanalysis_2001-2005.nc t2m_amz_neb_ncep_ncar_reanalysis_2001-2005_A8.nc


echo 
echo "3. Statistics index (mean and sum)"

echo
echo "Precipitation"
cdo monsum pre_amz_neb_cmap_observation_2001-2005_A0.nc pre_amz_neb_cmap_observation_2001-2005_A0_monsum.nc
cdo monmean pre_amz_neb_cmap_observation_2001-2005_A0.nc pre_amz_neb_cmap_observation_2001-2005_A0_monmean.nc
cdo ymonmean pre_amz_neb_cmap_observation_2001-2005_A0_monmean.nc pre_amz_neb_cmap_observation_2001-2005_A0_clim.nc

echo
echo "Temperature 2m"
cdo monsum t2m_amz_neb_ncep_ncar_reanalysis_2001-2005_A0.nc t2m_amz_neb_ncep_ncar_reanalysis_2001-2005_A0_monsum.nc
cdo monmean t2m_amz_neb_ncep_ncar_reanalysis_2001-2005_A0.nc t2m_amz_neb_ncep_ncar_reanalysis_2001-2005_A0_monmean.nc
cdo ymonmean t2m_amz_neb_ncep_ncar_reanalysis_2001-2005_A0_monmean.nc t2m_amz_neb_ncep_ncar_reanalysis_2001-2005_A0_clim.nc


echo
echo "--------------- END PREPROCESSING OBS ----------------"















