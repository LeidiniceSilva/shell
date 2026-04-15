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
#__date__        = 'Jan 20, 2026'
#__description__ = 'Posprocessing the RegCM with CDO'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DOMAIN="CAR-4"  # CSAM-3 EURR-3
EXP="ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1"

if [ ${DOMAIN} = 'CAR-3'  ]; then
	DIR_I="/leonardo_work/ICT26_ESP/CORDEX-CMIP6/DD/CAR-4/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr"
elif [ ${DOMAIN} = 'CSAM-3'  ]; then
	DIR_I="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/ERA5/ERA5-CSAM-3/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr"
elif [ ${DOMAIN} = 'EURR-3'  ]; then
	DIR_I="/leonardo_work/ICT26_ESP/jdeleeuw/EURR-3/ERA5/high_soil_moisture/ERA5/EURR-3/postproc/CORDEX-CMIP6/DD/EURR-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr"
else
	echo "Error: Unknown DOMAIN = ${DOMAIN}"
	exit 1
fi	

DIR_II="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/${DOMAIN}/input"

echo
cd ${DIR_II}
echo ${DIR_II}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

CDO mergetime ${DIR_I}/pr_* pr_${DOMAIN}_${EXP}_1hr_2000-2009.nc
CDO mergetime /leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/EURR-3/input/Tb/Tb_* Tb_${DOMAIN}_${EXP}_1hr_2000-2009.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}

