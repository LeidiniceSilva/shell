#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the RegCM5 output with CDO'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DOMAIN="AUS-12"
MDL_LIST="EC-Earth3-Veg MPI-ESM1-2-HR"
#MDL_LIST="EC-Earth3-Veg MPI-ESM1-2-HR NorESM2-MM"
VAR_LIST="pr tas tasmax tasmin"

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/trend/${DOMAIN}"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "Select variable"
for MDL in ${MDL_LIST[@]}; do
    for VAR in ${VAR_LIST[@]}; do

	if [ ${DOMAIN} = 'AUS-12'  ]
	then
	DIR_IN="/leonardo_work/ICT26_ESP/fraffael/CORDEX/pycordexed/CORDEX-CMIP6/DD/${DOMAIN}/ICTP/${MDL}/historical/r1i1p1f1/RegCM5-0/v1-r1/day/${VAR}"
	elif [ ${DOMAIN} = 'CAM-12'  ]
	then
	DIR_IN="/leonardo_work/ICT26_ESP/jdeleeuw/EURR-3/ERA5/high_soil_moisture/ERA5/EURR-3/analysis/yearly/"
	elif [ ${DOMAIN} = 'EUR-12'  ]
	then
	DIR_IN="/leonardo_work/ICT26_ESP/jdeleeuw/EURR-3/ERA5/high_soil_moisture/ERA5/EURR-3/analysis/yearly/"
	elif [ ${DOMAIN} = 'NAM-12'  ]
	then
	DIR_IN="/leonardo_work/ICT26_ESP/nzazulie/${DOMAIN}/${MDL}/NoTo-SouthAmerica"
	elif [ ${DOMAIN} = 'SAM-12'  ]
	then
	DIR_IN="/leonardo_work/ICT25_ESP/nzazulie/${DOMAIN}/MPI/NoTo-SouthAmerica"
	else
	DIR_IN="/leonardo_work/ICT26_ESP/jdeleeuw/${DOMAIN}/ECEarth/CMIP6"
	fi	

	CDO mergetime ${DIR_IN}/${VAR}_${DOMAIN}_${MDL}_historical_r1i1p1f1_ICTP_RegCM5-0_v1-r1_day* ${VAR}_${DOMAIN}_${MDL}_RegCM5_1970-2014.nc

	if [ ${VAR} = 'pr'  ]
	then
	CDO mulc,86400 ${VAR}_${DOMAIN}_${MDL}_RegCM5_1970-2014.nc ${VAR}_${DOMAIN}_${MDL}_RegCM5_day_1970-2014.nc
	CDO yearsum ${VAR}_${DOMAIN}_${MDL}_RegCM5_day_1970-2014.nc ${VAR}_${DOMAIN}_${MDL}_RegCM5_year_1970-2014.nc
	else
	CDO -b f32 subc,273.15 ${VAR}_${DOMAIN}_${MDL}_RegCM5_1970-2014.nc ${VAR}_${DOMAIN}_${MDL}_RegCM5_day_1970-2014.nc
	CDO yearmean ${VAR}_${DOMAIN}_${MDL}_RegCM5_day_1970-2014.nc ${VAR}_${DOMAIN}_${MDL}_RegCM5_year_1970-2014.nc
	fi

	rm ${VAR}_${DOMAIN}_${MDL}_RegCM5_1970-2014.nc
	rm ${VAR}_${DOMAIN}_${MDL}_RegCM5_day_1970-2014.nc

    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}


