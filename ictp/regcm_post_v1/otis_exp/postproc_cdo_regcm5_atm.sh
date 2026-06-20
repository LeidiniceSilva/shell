#!/bin/bash

#SBATCH -A ICT26_ESP
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
set -eo pipefail

DOMAIN_LIST="large"
EXP_LIST="ctrl holt_r2 holt_r3 uw_r2 uw_r3"
VAR_LIST="hus ta ua va wa"
DATE="2023101200" # 2023101200 2023102000 

DIR_BIN="/leonardo/home/userexternal/ggiulian/binaries_CORDEX5"
DIR_NAMELIST="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v1/otis_exp"
DIR_WIND="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts_regcm"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "1. Convert sigma2p & rotate wind"
for DOMAIN in ${DOMAIN_LIST[@]}; do
	for EXP in ${EXP_LIST[@]}; do

		DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_scratch/Otis_exp/exps_v4/domain_${DOMAIN}/${EXP}/output"
		DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/Otis_exp/exps/exps_v4/domain_${DOMAIN}/${EXP}"

		echo
		cd ${DIR_IN}
		echo ${DIR_IN}

		${DIR_BIN}/./sigma2pCLM45 ${DIR_NAMELIST}/RegCM5-ERA5_Otis_domain_${DOMAIN}.in Otis_exp_ATM.${DATE}.nc
		python3 ${DIR_WIND}/rotatewinds.py Otis_exp_ATM.${DATE}_pressure.nc

    		echo
    		echo "2. Select variable"
    		for VAR in ${VAR_LIST[@]}; do
        		CDO selname,${VAR} Otis_exp_ATM.${DATE}_pressure.nc ${DIR_OUT}/${VAR}_${EXP}_${DATE}.nc
    		done


	done    
done 

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
