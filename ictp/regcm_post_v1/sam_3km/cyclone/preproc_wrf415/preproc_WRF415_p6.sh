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
#__date__        = 'May 28, 2024'
#__description__ = 'Posprocessing the WRF output with CDO'
 
{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

MODEL="WRF415"
VAR_LIST="U10e V10e U10 V10 PREC_ACC_NC" 

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/WRF415/WRF2d"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do

    DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/WRF415/${VAR}"
    
    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}

    for YEAR in `seq -w 2018 2021`; do
        for MON in `seq -w 01 12`; do
            CDO selvar,${VAR} ${DIR_IN}/wrf2d_ml_saag_${YEAR}${MON}.nc ${VAR}_${MODEL}_${YEAR}${MON}.nc
	done
    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL -------------"

}
