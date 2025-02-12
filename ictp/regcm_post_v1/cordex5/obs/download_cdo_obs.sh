#!/bin/bash

#SBATCH -A ICT23_ESP_1
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Download
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jan 02, 2024'
#__description__ = 'Download and select domain in CMORPH data'

{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

# Function to check the leap year
is_leap_year() {
	YEAR=$1
	if [ $((YEAR % 4)) -eq 0 ]; then
		if [ $((YEAR % 100)) -ne 0 ] || [ $((YEAR % 400)) -eq 0 ]; then
			return 0  # Leap year
		else
			return 1  # Not a leap year
        	fi
	else
        	return 1  # Not a leap year
	fi
}

YR0=2000
YR1=2009
MN0=01
MN1=12
HR0=00
HR1=23

PATH_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS/CMORPH"

echo
cd ${PATH_OUT}
echo ${PATH_OUT}

for YEAR in `seq -w ${YR0} ${YR1}`; do

	for MON in `seq -w ${MN0} ${MN1}`; do

		case ${MON} in
			01|03|05|07|08|10|12)
				DAYS=31
				;;
			04|06|09|11)
				DAYS=30
				;;
			02)
				if is_leap_year ${YEAR}; then
					DAYS=29
				else
					DAYS=28
				fi
				;;
		esac
		
		for DAY in `seq -w 01 ${DAYS}`; do
			
			for HOUR in `seq -w ${HR0} ${HR1}`; do

				echo
				echo "File: CMORPH_V1.0_ADJ_8km-30min_${YEAR}${MON}${DAY}${HOUR}.nc"
							
				wget -N https://www.ncei.noaa.gov/data/cmorph-high-resolution-global-precipitation-estimates/access/30min/8km/${YEAR}/${MON}/${DAY}/CMORPH_V1.0_ADJ_8km-30min_${YEAR}${MON}${DAY}${HOUR}.nc

				CDO sellonlatbox,-85,-30,-42,-8 CMORPH_V1.0_ADJ_8km-30min_${YEAR}${MON}${DAY}${HOUR}.nc CSAM-3_CMORPH_${YEAR}${MON}${DAY}${HOUR}.nc
				
				CDO hourmean CSAM-3_CMORPH_${YEAR}${MON}${DAY}${HOUR}.nc cmorph_CSAM-3_CMORPH_${YEAR}${MON}${DAY}${HOUR}.nc
				
				rm CSAM-3_CMORPH_${YEAR}${MON}${DAY}${HOUR}.nc
								
			done
		done
	done	
done

break

CDO mergetime cmorph_CSAM-3_CMORPH_2000*.nc cmorph_CSAM-3_CMORPH_1hr_2000.nc
CDO mergetime cmorph_CSAM-3_CMORPH_2001*.nc cmorph_CSAM-3_CMORPH_1hr_2001.nc
CDO mergetime cmorph_CSAM-3_CMORPH_2002*.nc cmorph_CSAM-3_CMORPH_1hr_2002.nc
CDO mergetime cmorph_CSAM-3_CMORPH_2003*.nc cmorph_CSAM-3_CMORPH_1hr_2003.nc
CDO mergetime cmorph_CSAM-3_CMORPH_2004*.nc cmorph_CSAM-3_CMORPH_1hr_2004.nc
CDO mergetime cmorph_CSAM-3_CMORPH_2005*.nc cmorph_CSAM-3_CMORPH_1hr_2005.nc
CDO mergetime cmorph_CSAM-3_CMORPH_2006*.nc cmorph_CSAM-3_CMORPH_1hr_2006.nc
CDO mergetime cmorph_CSAM-3_CMORPH_2007*.nc cmorph_CSAM-3_CMORPH_1hr_2007.nc
CDO mergetime cmorph_CSAM-3_CMORPH_2008*.nc cmorph_CSAM-3_CMORPH_1hr_2008.nc
CDO mergetime cmorph_CSAM-3_CMORPH_2009*.nc cmorph_CSAM-3_CMORPH_1hr_2009.nc

CDO mergetime cmorph_CSAM-3_CMORPH_1hr_200*.nc cmorph_CSAM-3_CMORPH_1hr_2000-2009.nc

rm cmorph_CSAM-3_CMORPH_2000*.nc

}
