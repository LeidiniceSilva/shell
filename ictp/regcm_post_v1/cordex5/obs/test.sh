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
YR1=2004
MN0=01
MN1=12
HR0=00
HR1=23

PATH_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS/CMORPH"

echo
cd ${PATH_OUT}
echo ${PATH_OUT}

CDO mergetime cmorph_CSAM-3_CMORPH_2000*.nc cmorph_CSAM-3_CMORPH_1hr_2000.nc
CDO mergetime cmorph_CSAM-3_CMORPH_2001*.nc cmorph_CSAM-3_CMORPH_1hr_2001.nc
CDO mergetime cmorph_CSAM-3_CMORPH_2002*.nc cmorph_CSAM-3_CMORPH_1hr_2002.nc
CDO mergetime cmorph_CSAM-3_CMORPH_2003*.nc cmorph_CSAM-3_CMORPH_1hr_2003.nc
CDO mergetime cmorph_CSAM-3_CMORPH_2004*.nc cmorph_CSAM-3_CMORPH_1hr_2004.nc

rm cmorph_CSAM-3_CMORPH_2000*.nc

}
