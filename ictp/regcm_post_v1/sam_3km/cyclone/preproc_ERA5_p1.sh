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
#__description__ = 'Posprocessing the dataset with CDO'

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

# Change path
path1='/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/obs/era5'
path2='/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/obs/track_p1'

# Set file name
filename='SAM-25km_ERA5'
dt= '2018010100-2021123100'

# Datetime
anoi=2018
anof=2021 

for var in u v msl; do
    
    for yr in $(seq $anoi $anof); do
    CDO selyear,$yr ${path1}/${var}_${filename}_${dt}.nc ${path2}/${var}_${filename}_${yr}.nc 
   	
	for hr in 00 06 12 18; do
            CDO selhour,$hr ${path2}/${var}_${filename}_${yr}.nc ${path2}/${var}.${yr}.${hr}.nc
        
	done
    done
done

}


