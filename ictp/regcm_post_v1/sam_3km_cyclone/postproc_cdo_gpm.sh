#!/bin/bash

#SBATCH -N 1 
#SBATCH -t 24:00:00
#SBATCH -A ICT23_ESP
#SBATCH --qos=qos_prio
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p skl_usr_prod

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jun 10, 2024'
#__description__ = 'Post-processing GPM'

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

dir_out=/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/obs/gpm

for year in $(seq 2018 2021); do
	for mon in {01..12}; do
		for day in {01..31}; do

			dir_in=/home/esp-shared-a/Observations/GPM/IMERG/FINAL/V07A/$year/$mon/$day

			for min in $(seq -w 0000 30 1410); do
				
				file=3B-HHR.MS.MRG.3IMERG.${year}${mon}${day}-S*-E*.${min}.V07A.nc	
      				ls $file
      			
      				cdo sellonlatbox,-79,-34,-36,-10 $dir_in/$file $dir_out/precipitation_SAM_GPM_3B-HHR_${year}${mon}${day}_${min}_V07A.nc
      			done
    		done    		
	done
done

for year in $(seq 2018 2021); do

	cdo mergetime $dir_out/precipitation_SAM_GPM_3B-HHR_${year}*_V07A.nc $dir_out/precipitation_SAM_GPM_3B-HHR_${year}.nc

done

}
