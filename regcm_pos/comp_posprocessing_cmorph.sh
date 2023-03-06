#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '02/09/2023'
#__description__ = 'Posprocessing CMORPH satelite data'

for YEAR in 2018 2019 2020 2021; do
    for MON in 01 02 03 04 05 06 07 08 09 10 11 12; do
		for DAY in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31; do
			for HOUR in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23; do
    	    
				echo "Posprocessing: CMORPH_V1.0_ADJ_8km-30min_${YEAR}${MON}${DAY}${HOUR}.nc"
				
				echo "1. Set domain: SESA"
				cdo sellonlatbox,-80,-30,-40,-10 CMORPH_V1.0_ADJ_8km-30min_${YEAR}${MON}${DAY}${HOUR}.nc CMORPH_V1.0_ADJ_SA_8km-30min_${YEAR}${MON}${DAY}${HOUR}.nc
				
				echo "2. Convert frequence: Hourly"				
				cdo hoursum CMORPH_V1.0_ADJ_SA_8km-30min_${YEAR}${MON}${DAY}${HOUR}.nc CMORPH_V1.0_ADJ_SA_8km_hr_${YEAR}${MON}${DAY}${HOUR}.nc
				
				rm CMORPH_V1.0_ADJ_SA_8km-30min_${YEAR}${MON}${DAY}${HOUR}.nc
				
			done
        done
    done
done	

echo "3. Concatenate files"			
cdo cat CMORPH_V1.0_ADJ_SA_8km_hr_*.nc CMORPH_V1.0_ADJ_SA_8km_hr_2018-2019.nc

echo "4. Convert frequence: Daily"			
cdo daysum CMORPH_V1.0_ADJ_SA_8km_hr_2018-2019.nc  CMORPH_V1.0_ADJ_SA_8km_day_2018-2019.nc

echo "5. Convert frequence: Monthly"			
cdo monavg CMORPH_V1.0_ADJ_SA_8km_day_2018-2019.nc  CMORPH_V1.0_ADJ_SA_8km_mon_2018-2019.nc

echo "6. Regid: 4km"			
/home/nice/Documentos/github_projects/shell/regcm_pos/./regrid CMORPH_V1.0_ADJ_SA_8km_mon_2018-2019.nc -40,-10,0.0352 -80,-30,0.0352 bil

echo "7. Convert frequence: Seasonaly"			
cdo -r -timselavg,3 -selmon,1,2,12 CMORPH_V1.0_ADJ_SA_8km_mon_2018-2019_lonlat.nc CMORPH_V1.0_ADJ_SA_8km_djf_2018-2019_lonlat.nc
cdo -r -timselavg,3 -selmon,3,4,5 CMORPH_V1.0_ADJ_SA_8km_mon_2018-2019_lonlat.nc CMORPH_V1.0_ADJ_SA_8km_mam_2018-2019_lonlat.nc
cdo -r -timselavg,3 -selmon,6,7,8 CMORPH_V1.0_ADJ_SA_8km_mon_2018-2019_lonlat.nc CMORPH_V1.0_ADJ_SA_8km_jja_2018-2019_lonlat.nc
cdo -r -timselavg,3 -selmon,9,10,11 CMORPH_V1.0_ADJ_SA_8km_mon_2018-2019_lonlat.nc CMORPH_V1.0_ADJ_SA_8km_son_2018-2019_lonlat.nc
