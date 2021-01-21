#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '05/26/18'
#__description__ = 'Posprocessing the RegCM4.6.0 model and ERA5 data with CDO'


echo "1. Select variable"
cdo selname,pr file_in.nc file_out.nc

 
echo "2. Select date"
cdo seldate,2017-05-20T00:00:00,2017-05-30T00:00:00 file_in.nc file_out.nc


echo "3. Standard calendar"
cdo -a setcalendar,standard file_in.nc file_out.nc


echo "4. Convert unit"
cdo mulc,86400 file_in.nc file_out.nc
cdo mulc,100 file_in.nc file_out.nc

 
echo "5. Remapbil"
cdo remapbil,r1440x720 file_in.nc file_out.nc

 
echo "6. Sellonlatbox"
cdo sellonlatbox,-49.5,-20.5,-20,4.0 file_in.nc file_out.nc


echo "7. Statistics index"
cdo monmean file_in.nc file_out.nc



