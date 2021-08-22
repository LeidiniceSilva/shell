#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '12/22/2020'
#__description__ = 'Posprocessing the ERA5 reanalise data with CDO'
 

echo
echo "--------------- INIT POSPROCESSING ----------------"

echo 
echo "1. Select study area South America"
cdo sellonlatbox,-80,30,-60,20 mtpr_era5_mon_1979_2019.nc mtpr_era5_sa_mon_1979_2019.nc

echo 
echo "2. Convert unit m to mm per month"
cdo -r -b 32 mulc,2592000 mtpr_era5_sa_mon_1979_2019.nc mtpr_era5_sa_mon_1979_2019_mm.nc

echo 
echo "3. Split month"
cdo splitmon mtpr_era5_sa_mon_1979_2019_mm.nc month

echo 
echo "4. Compute anomaly per month"
cdo ymonsub month01.nc -ymonavg month01.nc anom_month01.nc
cdo ymonsub month02.nc -ymonavg month02.nc anom_month02.nc
cdo ymonsub month03.nc -ymonavg month03.nc anom_month03.nc
cdo ymonsub month04.nc -ymonavg month04.nc anom_month04.nc
cdo ymonsub month05.nc -ymonavg month05.nc anom_month05.nc
cdo ymonsub month06.nc -ymonavg month06.nc anom_month06.nc
cdo ymonsub month07.nc -ymonavg month07.nc anom_month07.nc
cdo ymonsub month08.nc -ymonavg month08.nc anom_month08.nc
cdo ymonsub month09.nc -ymonavg month09.nc anom_month09.nc
cdo ymonsub month10.nc -ymonavg month10.nc anom_month10.nc
cdo ymonsub month11.nc -ymonavg month11.nc anom_month11.nc
cdo ymonsub month12.nc -ymonavg month12.nc anom_month12.nc

echo 
echo "5. Merge all time step"
cdo merge anom_month* anom_mtpr_era5_sa_mon_1979_2019_mm.nc

echo
echo "--------------- THE END POSPROCESSING ----------------"

