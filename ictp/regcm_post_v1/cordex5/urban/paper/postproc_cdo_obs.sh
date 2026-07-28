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
#__date__        = 'Jul 28, 2026'
#__description__ = 'Posprocessing the OBS output with CDO'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

FREQ="day"
YR="2000-2009"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

VAR_LIST="precip tmax tmin"

DIR_OBS="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS/CPC"

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/urban/paper"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING ----------------"

for VAR in ${VAR_LIST[@]}; do

    # Input files
    CPC_FILE="${DIR_OBS}/${VAR}.cpc.${FREQ}.1979-2024.nc"

    # Output files
    CPC_FILE_="${VAR}_CPC_${FREQ}_${YR}.nc"

    CDO selyear,${IYR}/${FYR} ${CPC_FILE} ${CPC_FILE_}

done

echo
echo "--------------- THE END POSPROCESSING ----------------"

}
