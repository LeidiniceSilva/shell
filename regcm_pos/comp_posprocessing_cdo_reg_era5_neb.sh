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


echo "7. Statistics index (r, BE, MAE, RMSE)"
cdo monmean file_in.nc file_out.nc



'reinit'
'set display color white'
'c'

'open /home/nice/Downloads/neb_STS.2017050100.nc.ctl'

'set t 26'
'set mpdset mresbr'
'set mproj scaled'
'set map 1 1 8'
'set vpage 0 11 0 8.5'
'set parea 1 5.95 5 8'
'set strsiz 0.20'
'set string 1 l 8'
'set grads off'
'set grid off'
'set gxout shaded'
'set xlab on'
'set ylab on'
'set xlopts 1 4 0.20'
'set ylopts 1 4 0.20'
'set ylint 5'
'set xlint 10'

'color 0.5 16 1 -kind white->darkblue->gray'
'set cmin 2'

'd pr*46800'
'draw title A) 26/05/2017'
********

'set t 27'
'set vpage 0 11 0 8.5'
'set parea 6 10.95 5 8'
'set strsiz 0.20'
'set string 1 l 8'
'set grads off'
'set grid off'
'set gxout shaded'
'set xlab on'
'set ylab off'
'set xlopts 1 4 0.20'
'set ylopts 1 4 0.20'
'set ylint 5'
'set xlint 10'

'color 0.5 16 1 -kind white->darkblue->gray'
'set cmin 2'

'd pr*46800'
'draw title B) 27/05/2017'
**************

'set t 28'
'set vpage 0 11 0 8.5'
'set parea 1 5.95 1 4'
'set strsiz 0.20'
'set string 1 l 8'
'set grads off'
'set grid off'
'set gxout shaded'
'set xlab on'
'set ylab on'
'set xlopts 1 4 0.20'
'set ylopts 1 4 0.20'
'set ylint 5'
'set xlint 10'

'color 0.5 16 1 -kind white->darkblue->gray'
'set cmin 2'

'd pr*46800'
'draw title C) 29/05/2017'
**************

'set t 29'
'set vpage 0 11 0 8.5'
'set parea 6 10.95 1 4'
'set strsiz 0.20'
'set string 1 l 8'
'set grads off'
'set grid off'
'set gxout shaded'
'set xlab on'
'set ylab off'
'set xlopts 1 4 0.20'
'set ylopts 1 4 0.20'
'set ylint 5'
'set xlint 10'

'color 0.5 16 1 -kind white->darkblue->gray'
'set cmin 2'

'd pr*46800'
'draw title D) 30/05/2017'
'draw string 0.20 0.40 RCM'
'draw string 10 0.40 (mm)'
'cbarn'

'printim /home/nice/Downloads/maps_reg_neb.png white'
break

