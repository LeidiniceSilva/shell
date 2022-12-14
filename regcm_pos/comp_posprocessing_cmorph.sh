#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '12/12/2022'
#__description__ = 'Download CMORPH contour data'


for YEAR in 2018; do
    for MON in 01 02 03 04 05 06 07 08 09 10 11 12; do
		for DAY in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31; do
			for HOUR in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23; do
    	    
				echo "CMORPH_V1.0_ADJ_8km-30min_${YEAR}${MON}${DAY}${HOUR}.nc"
		        #~ /home/nice/Documentos/github_projects/shell/regcm_pos/./regrid CMORPH_V1.0_ADJ_8km-30min_${YEAR}${MON}${DAY}${HOUR}.nc -40,-10,0.0352 -80,-30,0.0352 bil
				#~ cdo sellonlatbox,-80,-30,-40,-10 CMORPH_V1.0_ADJ_8km-30min_${YEAR}${MON}${DAY}${HOUR}.nc CMORPH_V1.0_ADJ_SA_8km-30min_${YEAR}${MON}${DAY}${HOUR}.nc
				cdo hoursum CMORPH_V1.0_ADJ_SA_8km-30min_${YEAR}${MON}${DAY}${HOUR}.nc CMORPH_V1.0_ADJ_SA_8km_hr_${YEAR}${MON}${DAY}${HOUR}.nc

			done
        done
    done
done	
