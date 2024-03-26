#!/bin/bash
 
#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 15, 2024'
#__description__ = 'Preprocess RegCM5 output to track cyclone'

{

set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

# Change path
path="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/rcm/regcm5"

# Set file name
var_list="psl ua va"
file="SAM-3km_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5"
file1="SAM-3km_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_1hr"
file2="SAM-3km_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_6hr"
dt="20180101-20211231"

# Datetime
anoi=2018
anof=2021 

for var in ${var_list[@]}; do 
    
    for yr in $(seq $anoi $anof); do
        if [ ${var} == 'psl' ]
	then
        CDO selyear,$yr ${path}/${var}/${var}_${file1}_${dt}.nc ${path}/${var}/${var}_${file}_${yr}.nc 
	else
        CDO selyear,$yr ${path}/${var}/${var}_${file2}_${dt}.nc ${path}/${var}/${var}_${file}_${yr}.nc 
	fi
	
	for hr in 00 06 12 18; do
            CDO selhour,$hr ${path}/${var}/${var}_${file}_${yr}.nc ${path}/preproc/${var}.${yr}.${hr}.nc
	                
	done
    done
done

#rm ${path}/${var}_${file}_*.nc

}


