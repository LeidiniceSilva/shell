#!/bin/bash

#SBATCH -A ICT25_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J rotate_wind
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 12, 2024'
#__description__ = 'Posprocessing the RegCM5 output with CDO'

{
set -eo pipefail

EXP="EUR-11"

YR="2000-2009"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

FOLDER_LIST="NoTo-EUR WSM5-EUR WSM7-EUR WDM7-EUR"

echo
echo "--------------- INIT POSTPROCESSING MODEL ----------------"

for FOLDER in ${FOLDER_LIST[@]}; do

    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/${FOLDER}"
    WIND="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts_regcm"

    echo
    cd ${DIR_IN}
    echo ${DIR_IN}

    echo
    echo "1. Convert to sigma to pressure"
    for YEAR in `seq -w ${IYR} ${FYR}`; do
	for MON in `seq -w 01 12`; do

	    python3 ${WIND}/rotatewinds.py ${EXP}_ATM.${YEAR}${MON}0100_pressure.nc
	   
	done
    done
done
    
echo
echo "--------------- THE END POSTPROCESSING MODEL ----------------"

}
