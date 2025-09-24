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
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DOMAIN_LIST="large small"
EXP_LIST="ctrl holt_r2 holt_r3 uw_r2 uw_r3"
VAR_LIST="hus ta ua va wa"

DIR_WIND="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts_regcm"
DIR_NAMELIST="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v1/tcyclone"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "1. Rotate wind"
for DOMAIN in ${DOMAIN_LIST[@]}; do
	for EXP in ${EXP_LIST[@]}; do

		DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_scratch/Otis_exp/domain_${DOMAIN}/${EXP}/output"
		DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/Otis_exp/domain_${DOMAIN}/${EXP}"

		echo
		cd ${DIR_IN}
		echo ${DIR_IN}

    		python3 ${DIR_WIND}/rotatewinds.py Otis_exp_ATM.2023101900_pressure.nc

    		echo
    		echo "2. Select variable"
    		for VAR in ${VAR_LIST[@]}; do
        		CDO selname,${VAR} Otis_exp_ATM.2023101900_pressure.nc ${DIR_OUT}/${VAR}_${EXP}_2023101900.nc
    		done
	done    
done 

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
