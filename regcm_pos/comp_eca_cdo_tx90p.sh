#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '01/01/2021'
#__description__ = 'Calculate extreme index with ECA_CDO'

echo
echo "--------------- INIT CALCULATE EXTREME INDICES ETCCDI ----------------"
echo

TMAX_RF="tasmax_amz_neb_HadGEM2-ES_historical_1986-2005_lonlat_seamask.nc"
TMAX="tasmax_amz_neb_HadGEM2-ES_rcp26_2080-2099_lonlat_seamask.nc"

cdo timmin ${TMAX_RF} minfile.nc
cdo timmax ${TMAX_RF} maxfile.nc
cdo timpctl,90 ${TMAX_RF} minfile.nc maxfile.nc tmax_90th_percentile_1986-2005.nc
rm -rf minfile.nc maxfile.nc

for YEAR in {2080..2099} ; do

    echo
    echo "# Running -->" ${YEAR}
    echo
    
    cdo selyear,${YEAR} ${TMAX} TMAX_${YEAR}.nc
    
    ntime=`cdo ntime TMAX_${YEAR}.nc`
    cdo duplicate,${ntime} tmax_90th_percentile_1986-2005.nc tmax_90th_percentile_1986-2005_ntime.nc
    cdo eca_tx90p TMAX_${YEAR}.nc tmax_90th_percentile_1986-2005_ntime.nc tx90p_${YEAR}.nc

    rm -rf TMAX_${YEAR}.nc
    rm -rf tmax_90th_percentile_1986-2005_ntime.nc

done

cdo cat tx90p_????.nc eca_tx90p_amz_neb_HadGEM2-ES_rcp26_yr_2080-2099_lonlat.nc
rm -rf tx90p_????.nc
rm -rf tmax_90th_percentile_1986-2005.nc

echo
echo "--------------- THE END CALCULATE EXTREME INDICES ETCCDI ----------------"
echo




