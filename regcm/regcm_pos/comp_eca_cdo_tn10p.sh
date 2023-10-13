#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '01/01/2021'
#__description__ = 'Calculate extreme index with ECA_CDO'

echo
echo "--------------- INIT CALCULATE EXTREME INDICES ETCCDI ----------------"
echo

TMIN_RF="tasmin_amz_neb_HadGEM2-ES_historical_1986-2005_lonlat_seamask.nc"
TMIN="tasmin_amz_neb_HadGEM2-ES_rcp26_2080-2099_lonlat_seamask.nc"

cdo timmin ${TMIN_RF} minfile.nc
cdo timmax ${TMIN_RF} maxfile.nc
cdo timpctl,10 ${TMIN_RF} minfile.nc maxfile.nc tmin_10th_percentile_1986-2005.nc
rm -rf minfile.nc maxfile.nc

for YEAR in {2080..2099} ; do

    echo
    echo "# Running -->" ${YEAR}
    echo
    
    cdo selyear,${YEAR} ${TMIN} TMIN_${YEAR}.nc
    
    ntime=`cdo ntime TMIN_${YEAR}.nc`
    cdo duplicate,${ntime} tmin_10th_percentile_1986-2005.nc tmin_10th_percentile_1986-2005_ntime.nc
    cdo eca_tn10p TMIN_${YEAR}.nc tmin_10th_percentile_1986-2005_ntime.nc tn10p_${YEAR}.nc

    rm -rf TMIN_${YEAR}.nc
    rm -rf tmin_10th_percentile_1986-2005_ntime.nc

done

cdo cat tn10p_????.nc eca_tn10p_amz_neb_HadGEM2-ES_rcp26_yr_2080-2099_lonlat.nc
rm -rf tn10p_????.nc
rm -rf tmin_10th_percentile_1986-2005.nc

echo
echo "--------------- THE END CALCULATE EXTREME INDICES ETCCDI ----------------"
echo




