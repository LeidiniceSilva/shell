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
#__date__        = 'Jan 30, 2026'
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 
{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DOMAIN="SAM-12"
MDL="EC-Earth3-Veg"
VAR_LIST="tasmax tasmin"

DIR_IN="/leonardo_work/ICT26_ESP/nzazulie/SAM-12/ECEarth/NoTo-SouthAmerica"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/trend/SAM-12"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSTPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    for YEAR in `seq -w 1970 1980`; do
        for MON in `seq -w 01 12`; do
            CDO selname,${VAR} ${DIR_IN}/${DOMAIN}_STS.${YEAR}${MON}0100.nc ${VAR}_${DOMAIN}_${YEAR}${MON}01.nc 
	done
    done
    CDO mergetime ${VAR}_${DOMAIN}_*01.nc ${VAR}_${DOMAIN}_${MDL}_RegCM5_1970-2014.nc 
    if [ ${VAR} == 'pr' ]
    then
    CDO -b f32 mulc,86400 ${VAR}_${DOMAIN}_${MDL}_RegCM5_1970-2014.nc ${VAR}_${DOMAIN}_${MDL}_RegCM5_day_1970-2014.nc 
    CDO yearsum ${VAR}_${DOMAIN}_${MDL}_RegCM5_day_1970-2014.nc ${VAR}_${DOMAIN}_${MDL}_RegCM5_year_1970-2014.nc 
    else 
    CDO -b f32 subc,273.15 ${VAR}_${DOMAIN}_${MDL}_RegCM5_1970-2014.nc ${VAR}_${DOMAIN}_${MDL}_RegCM5_day_1970-2014.nc 
    CDO yearmean ${VAR}_${DOMAIN}_${MDL}_RegCM5_day_1970-2014.nc ${VAR}_${DOMAIN}_${MDL}_RegCM5_year_1970-2014.nc 
    fi
done

echo 
echo "Delete files"
#rm *01.nc
#rm *RegCM5_1970-2014.nc 
#rm *day_1970-2014.nc 

echo
echo "--------------- THE END POSTPROCESSING MODEL ----------------"

}
