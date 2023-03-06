#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '02/09/2023'
#__description__ = 'Download CMORPH satelite data'

PATH="/home/nice/Documentos/FPS_SESA/database/cmorph"

for YEAR in 2018 2019 2020 2021; do
    for MON in 01 02 03 04 05 06 07 08 09 10 11 12; do
		for DAY in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31; do
			for HOUR in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23; do
    	    
				cd ${PATH}
				echo "1. Download file: CMORPH_V1.0_ADJ_8km-30min_${YEAR}${MON}${DAY}${HOUR}.nc"
				
				/usr/bin/wget -N https://www.ncei.noaa.gov/data/cmorph-high-resolution-global-precipitation-estimates/access/30min/8km/${YEAR}/${MON}/${DAY}/CMORPH_V1.0_ADJ_8km-30min_${YEAR}${MON}${DAY}${HOUR}.nc
				
			done
        done
    done
done	
