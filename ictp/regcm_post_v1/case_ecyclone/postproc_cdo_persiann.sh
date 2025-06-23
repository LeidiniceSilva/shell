#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jan 02, 2024'
#__description__ = 'Select domain in PERSIANN satelite estimated data'

PATH_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km-cyclone/post/obs/persiann/2023"
PATH_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km-cyclone/post/obs/persiann/post"

echo
cd ${PATH_OUT}
echo ${PATH_OUT}

for DAY in {150..243}; do
    for HOUR in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23; do
    
        echo
	echo "1. File: rgccs1h23${DAY}${HOUR}.bin.gz"
	cdo sellonlatbox,-85,-30,-50,-10 ${PATH_IN}/rgccs1h23${DAY}${HOUR}.nc prec_persiann_1hr_2023-${DAY}-${HOUR}.nc
	
    done
done
