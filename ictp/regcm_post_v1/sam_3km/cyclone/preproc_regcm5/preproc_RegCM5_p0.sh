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
#__date__        = 'Mar 15, 2024'
#__description__ = 'Postprocessing the RegCM5 output with CDO'
 
{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="SAM-3km"
MODEL="RegCM5"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/output"
WIND="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts_regcm"

echo
cd ${DIR_IN}
echo ${DIR_IN}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for YEAR in `seq -w 2021 2021`; do
    for MON in `seq -w 11 12`; do
	    
        echo
	echo "1. Rotate wind"
	python3 ${WIND}/rotatewinds.py ${EXP}_SRF.${YEAR}${MON}0100.nc

    done
done
    
echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
