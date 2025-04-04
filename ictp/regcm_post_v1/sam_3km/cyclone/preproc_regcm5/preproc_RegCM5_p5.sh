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

PYCORDEX="/leonardo/home/userexternal/ggiulian/pycordexer"
DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/output"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/cyclone/regcm"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo ${DIR_IN}
cd ${DIR_IN}

# start and end year(s)
YR0=2018
YR1=2021

# start and end month(s)
MN0=01
MN1=12

for YEAR in `seq -w ${YR0} ${YR1}`; do
    for MON in `seq -w ${MN0} ${MN1}`; do
    
    	python3 ${PYCORDEX}/pycordexer.py SAM-3km_ATM.${YEAR}${MON}0100.nc cape
	
    done
done

# List of variables
VAR_LIST="CAPE CIN"

for VAR in ${VAR_LIST[@]}; do
        
    CDO mergetime /CORDEX/CMIP6/DD/NONE/ICTP/NONE/none/NN/RegCM5-0/v1-r1/6hr/${VAR}/${VAR}_NONE_NONE_none_NN_ICTP_RegCM5-0_v1-r1_6hr_*.nc ${DIR_OUT}/${VAR}_${EXP}_${MODEL}_6hr_${DT}.nc
    ${BIN}/./regrid ${VAR}_${EXP}_${MODEL}_6hr_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil	
    
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
