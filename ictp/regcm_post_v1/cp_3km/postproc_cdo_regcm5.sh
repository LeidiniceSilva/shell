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
VAR_LIST="hus pr psl sfcWind ta tas ua uas va vas wa"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km-cyclone/output"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km-cyclone/post/rcm"
DIR_BIN="/marconi/home/userexternal/ggiulian/RegCM/bin"

echo
cd ${DIR_IN}
echo ${DIR_IN}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "1. Select variable: ${VAR}"
    for MON in `seq -w 06 07`; do
    	if [ ${VAR} = hus  ] || [ ${VAR} = ta  ] || [ ${VAR} = ua  ] || [ ${VAR} = va  ] || [ ${VAR} = wa  ]
	then
	${DIR_BIN}/./sigma2pCLM45 namelist.in ${EXP}_ATM.${YEAR}${MON}0100.nc
	CDO selname,${VAR} ${EXP}_ATM.${YEAR}${MON}0100_pressure.nc ${DIR_OUT}/${VAR}_${EXP}_${YEAR}${MON}0100.nc
	else
	CDO selname,${VAR} ${EXP}_SRF.${YEAR}${MON}0100.nc ${DIR_OUT}/${VAR}_${EXP}_${YEAR}${MON}0100.nc
	fi
    done   
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
