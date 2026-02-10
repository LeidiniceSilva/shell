#!/bin/bash

#SBATCH -A CMPNS_ictpclim
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J sigma2p
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Sept 24, 2025'
#__description__ = 'Posprocessing the RegCM5 output with CDO'

{
source /leonardo/home/userexternal/ggiulian/modules
set -eo pipefail

DOMAIN_LIST="small large"
EXP_LIST="ctrl holt_r2 holt_r3 uw_r2 uw_r3"

DIR_BIN="/leonardo/home/userexternal/ggiulian/binaries_CORDEX5"
DIR_NAMELIST="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v1/tcyclone"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "1. Convert sigma2p"
for DOMAIN in ${DOMAIN_LIST[@]}; do
	for EXP in ${EXP_LIST[@]}; do

		DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_scratch/Otis_exp/domain_${DOMAIN}/${EXP}/output"
		DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/Otis_exp/domain_${DOMAIN}/${EXP}"

		echo
		cd ${DIR_IN}
		echo ${DIR_IN}

		${DIR_BIN}/./sigma2pCLM45 ${DIR_NAMELIST}/RegCM5-ERA5_Otis_domain_${DOMAIN}.in Otis_exp_ATM.2023101900.nc
	done    
done 

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
