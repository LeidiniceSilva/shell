#!/bin/bash
 
#SBATCH -J preproctrack
#SBATCH -t 24:00:00
#SBATCH -A ICT23_ESP
#SBATCH --qos=qos_prio
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p skl_usr_prod
#SBATCH -N 1 --ntasks-per-node=20

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
path='/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/rcm'

# Set file name
filename='SAM-3km_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5'
filename1='SAM-3km_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_1hr'
filename2='SAM-3km_ECMWF-ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_6hr'

# Datetime
anoi=2018
anof=2021 
        
for yr in $(seq $anoi $anof); do
    
    for var in ua va psl; do
    
        if [ ${var} == 'psl' ]
	then
    	CDO -b F64 mergetime ${path}/${var}/${var}_${filename1}_${yr}*.nc ${path}/track/${var}_${filename}_${yr}.nc
	else
    	CDO -b F64 mergetime ${path}/${var}/${var}_925hPa_${filename2}_${yr}*.nc ${path}/track/${var}_${filename}_${yr}.nc	
	fi
	
	for hr in 00 06 12 18; do
            CDO selhour,$hr ${path}/track/${var}_${filename}_${yr}.nc ${path}/track/${var}.${yr}.${hr}.nc
        
	done
    done
done

}


