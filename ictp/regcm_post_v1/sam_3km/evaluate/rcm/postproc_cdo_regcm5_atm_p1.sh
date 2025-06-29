#!/bin/bash

#SBATCH -A ICT25_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J sigma2p
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Postprocessing the RegCM5 output with CDO'

{
set -eo pipefail

YR="2020-2020"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

EXP="SAM-3km"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/test/output"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_IN}
echo ${DIR_IN}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "1. Convert to sigma to pressure"
for YEAR in `seq -w ${IYR} ${FYR}`; do
    for MON in `seq -w 01 12`; do

	${BIN}/./sigma2pCLM45 ${EXP}_ATM.${YEAR}${MON}0100.nc
	${BIN}/./sigma2pCLM45 ${EXP}_RAD.${YEAR}${MON}0100.nc
	    
    done
done
    
echo
echo "--------------- THE END POSTPROCESSING MODEL ----------------"

}

