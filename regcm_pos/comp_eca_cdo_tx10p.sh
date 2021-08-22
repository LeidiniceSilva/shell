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
cdo timpctl,10 ${TMAX_RF} minfile.nc maxfile.nc tmax_10th_percentile_1986-2005.nc
rm -rf minfile.nc maxfile.nc

for YEAR in {2080..2099} ; do

    echo
    echo "# Running -->" ${YEAR}
    echo
    
    cdo selyear,${YEAR} ${TMAX} TMAX_${YEAR}.nc
    
    ntime=`cdo ntime TMAX_${YEAR}.nc`
    cdo duplicate,${ntime} tmax_10th_percentile_1986-2005.nc tmax_10th_percentile_1986-2005_ntime.nc
    cdo eca_tx10p TMAX_${YEAR}.nc tmax_10th_percentile_1986-2005_ntime.nc tx10p_${YEAR}.nc

    rm -rf TMAX_${YEAR}.nc
    rm -rf tmax_10th_percentile_1986-2005_ntime.nc

done

cdo cat tx10p_????.nc eca_tx10p_amz_neb_HadGEM2-ES_rcp26_yr_2080-2099_lonlat.nc
rm -rf tx10p_????.nc
rm -rf tmax_10th_percentile_1986-2005.nc

echo
echo "--------------- THE END CALCULATE EXTREME INDICES ETCCDI ----------------"
echo




