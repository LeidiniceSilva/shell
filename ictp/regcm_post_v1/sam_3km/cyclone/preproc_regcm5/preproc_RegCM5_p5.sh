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
#__date__        = 'Aug 23, 2024'
#__description__ = 'Create CAPE and CIN variables using PyCordex code'

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

PYCORDEX="/marconi/home/userexternal/ggiulian/pycordexer"
DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/output"
echo ${DIR_IN}
cd ${DIR_IN}

# start and end year(s)
YR0=2019
YR1=2019

# start and end month(s)
MN0=1
MN1=6

for YEAR in `seq -w ${YR0} ${YR1}`; do
    for MON in `seq -w ${MN0} ${MN1}`; do
    
    	python3 ${PYCORDEX}/pycordexer.py SAM-3km_ATM.${YEAR}${MON}0100.nc capecin
	
    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
