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

set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="AUS-12"
DOMAIN="NoTo-Australasia"

YR="1970-1970"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

DIR_IN="/leonardo_scratch/large/userexternal/fraffael/RegCM5test/ERA5/${DOMAIN}"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/TCYCLONE/${DOMAIN}"
WIND="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts_regcm"
REGRID="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v1/tcyclone/AUS-22_grid.txt"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for YEAR in `seq -w ${IYR} ${FYR}`; do
    for MON in `seq -w 01 12`; do

	CDO selhour,00,06,12,18 ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc ${EXP}_SRF.${YEAR}${MON}.nc
	python3 ${WIND}/rotatewinds.py ${EXP}_SRF.${YEAR}${MON}.nc
	CDO selvar,uas ${EXP}_SRF.${YEAR}${MON}.nc uas_${EXP}_${YEAR}${MON}.nc
	CDO selvar,vas ${EXP}_SRF.${YEAR}${MON}.nc vas_${EXP}_${YEAR}${MON}.nc
	CDO selvar,psl ${EXP}_SRF.${YEAR}${MON}.nc psl_${EXP}_${YEAR}${MON}.nc

    done
done

CDO mergetime uas_${EXP}_*.nc uas_${EXP}_RegCM5-ERA5_${IYR}.nc
CDO mergetime vas_${EXP}_*.nc vas_${EXP}_RegCM5-ERA5_${IYR}.nc
CDO mergetime psl_${EXP}_*.nc psl_${EXP}_RegCM5-ERA5_${IYR}.nc

CDO remapbil,${REGRID} uas_${EXP}_RegCM5-ERA5_${IYR}.nc uas.${EXP}.RegCM5-ERA5.${IYR}.nc
CDO remapbil,${REGRID} vas_${EXP}_RegCM5-ERA5_${IYR}.nc vas.${EXP}.RegCM5-ERA5.${IYR}.nc
CDO remapbil,${REGRID} psl_${EXP}_RegCM5-ERA5_${IYR}.nc psl.${EXP}.RegCM5-ERA5.${IYR}.nc

echo
echo "--------------- THE END POSTPROCESSING MODEL ----------------"

}
