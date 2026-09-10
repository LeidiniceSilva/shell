#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jan 20, 2026'
#__description__ = 'Posprocessing the RegCM with CDO'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DOMAIN_LIST=("CAR-4" "CSAM-3" "EURR-3")
EXP="ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1"
EXP_="ERA5_evaluation"

for DOMAIN in "${DOMAIN_LIST[@]}"; do

    REGRID="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/paper/dataset/GPM/${DOMAIN}/input"

    DIR="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/paper/dataset/CPMs/ICTP/${DOMAIN}/historical/ERA5/input"
    echo
    cd ${DIR}
    echo ${DIR}

    for YEAR in {2000..2009}; do
        for MONTH in {01..12}; do

	    CDO remapbil,${REGRID}/grid.txt ${DOMAIN}_${EXP}_1hr_${YEAR}${MONTH}0100.nc ${DOMAIN}_${EXP_}_1hr_${YEAR}${MONTH}0100.nc

	done
    done
done

}
