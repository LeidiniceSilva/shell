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
#__date__        = 'Aug 23, 2024'
#__description__ = 'Create CAPE and CIN variables using PyCordex code'

{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

PYCORDEX="/leonardo/home/userexternal/ggiulian"
DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/output"

echo ${DIR_IN}
cd ${DIR_IN}

# start and end year(s)
YR0=2018
YR1=2018

# start and end month(s)
MN0=01
MN1=03

for YEAR in `seq -w ${YR0} ${YR1}`; do
    for MON in `seq -w ${MN0} ${MN1}`; do
    
    	python3 ${PYCORDEX}/pycordexer.py SAM-3km_ATM.${YEAR}${MON}0100.nc capecin
	
    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
