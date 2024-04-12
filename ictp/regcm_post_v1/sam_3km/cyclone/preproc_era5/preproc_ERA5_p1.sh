#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 15, 2024'
#__description__ = 'Posprocessing the dataset with CDO'

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

# Change path
path1="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/obs/era5"
path2="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/obs/postproc"

# Set file name
var_list="t"
file="SAM-25km_ERA5_1hr"
dt="2018010100-2021123100"

# Datetime
anoi=2018
anof=2021 

for var in ${var_list[@]}; do
    
    for yr in $(seq $anoi $anof); do
        CDO selyear,$yr ${path1}/${var}_${file}_${dt}_lonlat.nc ${path2}/${var}_${file}_${yr}.nc 
   	
	for hr in 00 06 12 18; do
            CDO selhour,$hr ${path2}/${var}_${file}_${yr}.nc ${path2}/${var}.${yr}.${hr}.nc
	                
	done
    done
done

rm ${path2}/${var}_${file}_*.nc

}


