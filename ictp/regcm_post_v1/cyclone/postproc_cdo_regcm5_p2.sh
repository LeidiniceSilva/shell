#!/bin/bash

#SBATCH -A ICT25_ESP
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
#__description__ = 'Postprocessing the RegCM5 output with CDO'

{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="AUS-12"
DOMAIN="NoTo-Australasia"

YR="1970-1970"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CYCLONE/${DOMAIN}"
WIND="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts_regcm"
REGRID="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v1/cyclone/AUS-22_grid.txt"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

#for YEAR in `seq -w ${IYR} ${FYR}`; do
#    for MON in `seq -w 01 12`; do

	#python3 ${WIND}/rotatewinds.py ${EXP}_ATM.${YEAR}${MON}0100_pressure.nc
	#CDO sellevel,850,700,600,500,400,300,200 ${EXP}_ATM.${YEAR}${MON}0100_pressure.nc ${EXP}_ATM.${YEAR}${MON}.nc
	#CDO selname,ua ${EXP}_ATM.${YEAR}${MON}.nc ua_${EXP}_${YEAR}${MON}.nc
	#CDO selname,va ${EXP}_ATM.${YEAR}${MON}.nc va_${EXP}_${YEAR}${MON}.nc

#    done
#done

#CDO mergetime ua_${EXP}_*.nc ua_${EXP}_RegCM5-ERA5_${IYR}.nc
#CDO mergetime va_${EXP}_*.nc va_${EXP}_RegCM5-ERA5_${IYR}.nc

CDO remapbil,${REGRID} ua_${EXP}_RegCM5-ERA5_${IYR}.nc ua.${EXP}.RegCM5-ERA5.${IYR}.nc
CDO remapbil,${REGRID} va_${EXP}_RegCM5-ERA5_${IYR}.nc va.${EXP}.RegCM5-ERA5.${IYR}.nc

echo
echo "--------------- THE END POSTPROCESSING MODEL ----------------"

}
