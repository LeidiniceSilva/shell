#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jan 02, 2024'
#__description__ = 'Download CMORPH sateltite estimatimeted data'

PATH="/marconi/home/userexternal/mdasilva/user/mdasilva/cyclone/obs/cmorph"

echo
cd ${PATH}
echo ${PATH}

for YEAR in 2023; do
	for MON in 06 07 08; do
		for DAY in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31; do
			for HOUR in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23; do
    	    
				echo
				echo "1. Download file: CMORPH_V1.0_ADJ_8km-30min_${YEAR}${MON}${DAY}${HOUR}.nc"
								
				/usr/bin/wget -N https://www.ncei.noaa.gov/data/cmorph-high-resolution-global-precipitation-estimates/access/30min/8km/${YEAR}/${MON}/${DAY}/CMORPH_V1.0_ADJ_8km-30min_${YEAR}${MON}${DAY}${HOUR}.nc
				
			done
		done
	done
done	
