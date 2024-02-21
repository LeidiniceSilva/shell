#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jan 02, 2024'
#__description__ = 'Download PERSIANN satelite estimated data'

PATH="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km-cyclone/post/obs/persiann"

echo
cd ${PATH}
echo ${PATH}

START=150
FACTOR=1
END=243

for DAY in {150..243}; do
    for HOUR in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23; do
    
        echo
	echo "1. Download file: rgccs1h23${DAY}${HOUR}.bin.gz"
	/usr/bin/wget -N https://persiann.eng.uci.edu/CHRSdata/PERSIANN-CCS/hrly/2023/rgccs1h23${DAY}${HOUR}.bin.gz
	
    done
done
