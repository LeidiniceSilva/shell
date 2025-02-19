#!/bin/bash

#SBATCH -N 1
#SBATCH -t 24:00:00
#SBATCH -J Postproc
#SBATCH -p esp
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jun 10, 2024'
#__description__ = 'Post-processing GPM'

{

# load required modules
module purge
source /opt-ictp/ESMF/env202108

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

PATH_OUT="/home/mda_silv/scratch/GPM"

echo
cd ${PATH_OUT}
echo ${PATH_OUT}

for YEAR in $(seq 2018 2021); do
	for MON in {01..12}; do
		for DAY in {01..31}; do

			PATH_IN=/home/esp-shared-a/Observations/GPM/IMERG/FINAL/V07A/$YEAR/$MON/$DAY

			for MIN in $(seq -w 0000 30 1410); do
				
				FILE="precipitation_SAM_GPM_3B-HHR_${YEAR}${MON}${DAY}_${MIN}_V07A.nc"	
				if [ ! -f "$FILE" ]; then
      			
      				CDO sellonlatbox,-85,-30,-42,-8 $PATH_IN/3B-HHR.MS.MRG.3IMERG.${YEAR}${MON}${DAY}-S*-E*.${MIN}.V07A.nc $FILE
				
				fi
      			done
    		done    		
	done
done

CDO mergetime precipitation_SAM_GPM_3B-HHR_2018*_V07A.nc precipitation_SAM_GPM_3B-HHR_2018.nc
CDO mergetime precipitation_SAM_GPM_3B-HHR_2019*_V07A.nc precipitation_SAM_GPM_3B-HHR_2019.nc
CDO mergetime precipitation_SAM_GPM_3B-HHR_2020*_V07A.nc precipitation_SAM_GPM_3B-HHR_2020.nc
CDO mergetime precipitation_SAM_GPM_3B-HHR_2021*_V07A.nc precipitation_SAM_GPM_3B-HHR_2021.nc

}
