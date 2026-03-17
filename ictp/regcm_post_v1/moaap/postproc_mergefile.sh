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

DOMAIN="CSAM-3"
EXP="ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1"

if [ ${DOMAIN} = 'CAR-3'  ]; then
	DIR_I="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/ERA5/ERA5-CSAM-3/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr"
	
elif [ ${DOMAIN} = 'CSAM-3'  ]; then
	DIR_I="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/ERA5/ERA5-CSAM-3/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr"
else
	DIR_I="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/ERA5/ERA5-CSAM-3/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr"
fi	

DIR_II="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/${DOMAIN}/input/Tb"

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/${DOMAIN}/input"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

CDO mergetime ${DIR_I}/pr_* pr_${DOMAIN}_${EXP}_1hr_2000-2009.nc
CDO mergetime ${DIR_II}/Tb_* Tb_${DOMAIN}_${EXP}_1hr_2000-2009.nc
CDO merge pr_${DOMAIN}_${EXP}_1hr_2000-2009.nc Tb_${DOMAIN}_${EXP}_1hr_2000-2009.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
