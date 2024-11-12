#!/bin/bash

#SBATCH -N 1 
#SBATCH -t 24:00:00
#SBATCH -J Postproc
#SBATCH --qos=qos_prio
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p long

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the RegCM5 output with CDO'

# load required modules
module purge
source /opt-ictp/ESMF/env202108
set -e

{

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="2000-2000"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

CONF=$1
EXP="EUR-11"

DIR_IN="/home/mda_silv/scratch/EUR-11/${CONF}"
BIN="/home/mda_silv/github_projects/shell/ictp/regcm_post_v2/scripts/bin"
WIND="/home/mda_silv/github_projects/shell/ictp/regcm_post_v2/scripts_regcm"

echo
cd ${DIR_IN}
echo ${DIR_IN}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"


echo
echo "1. Convert sigma2p"
for YEAR in `seq -w ${IYR} ${FYR}`; do
    for MON in `seq -w 01 01`; do
          
	${BIN}/./sigma2pCLM45 ${EXP}_RAD.${YEAR}${MON}0100.nc
	${BIN}/./sigma2pCLM45 ${EXP}_ATM.${YEAR}${MON}0100.nc
	python3 ${WIND}/rotatewinds.py ${EXP}_ATM.${YEAR}${MON}0100_pressure.nc


    done 
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
