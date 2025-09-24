#!/bin/bash

#SBATCH -N 1 
#SBATCH -t 24:00:00
#SBATCH -A ICT23_ESP
#SBATCH --qos=qos_prio
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p skl_usr_prod

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jan 02, 2024'
#__description__ = 'Posprocessing the RegCM5 output with CDO'

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="SAM-3km-cyclone"
YEAR="2023"
VAR_LIST="hus ta ua va wa"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km-cyclone/output"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km-cyclone/post/rcm"

DIR_BIN="/marconi/home/userexternal/ggiulian/RegCM/bin"
DIR_WIND="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts_regcm"
DIR_NAMELIST="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_exp/sam_3km_cyclone"

echo
cd ${DIR_IN}
echo ${DIR_IN}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "1. Convert sigma2p and rotate wind"
for MON in `seq -w 06 07`; do

    ${DIR_BIN}/./sigma2pCLM45 ${DIR_NAMELIST}/namelist.in ${EXP}_ATM.${YEAR}${MON}0100.nc
    python3 ${DIR_WIND}/rotatewinds.py ${EXP}_ATM.${YEAR}${MON}0100_pressure.nc

    echo
    echo "2. Select variable"
    for VAR in ${VAR_LIST[@]}; do
        CDO selname,${VAR} ${EXP}_ATM.${YEAR}${MON}0100_pressure.nc ${DIR_OUT}/${VAR}_${EXP}_${YEAR}${MON}0100.nc
    done
    
done 

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
