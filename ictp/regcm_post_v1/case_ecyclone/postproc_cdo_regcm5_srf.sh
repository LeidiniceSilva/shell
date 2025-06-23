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
VAR_LIST="pr psl sfcWind tas uas vas"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km-cyclone/output"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km-cyclone/post/rcm"

echo
cd ${DIR_IN}
echo ${DIR_IN}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "1. Select variable: ${VAR}"
for VAR in ${VAR_LIST[@]}; do
    for MON in `seq -w 06 07`; do
	CDO selname,${VAR} ${EXP}_SRF.${YEAR}${MON}0100.nc ${DIR_OUT}/${VAR}_${EXP}_${YEAR}${MON}0100.nc
    done   
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
