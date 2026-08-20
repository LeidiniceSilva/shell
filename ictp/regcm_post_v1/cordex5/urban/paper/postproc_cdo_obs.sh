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

YR="2000-2009"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

DATASET="ERA5"
DIR_OBS="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS/${DATASET}"

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/urban/paper"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING ----------------"

if [ ${DATASET} == 'CPC' ]
then
VAR_LIST="precip tmax tmin"
for VAR in ${VAR_LIST[@]}; do

    # Input files
    FILE="${DIR_OBS}/${VAR}.cpc.day.1979-2024.nc"

    # Output files
    FILE_="${VAR}_${DATASET}_day_${YR}.nc"

    CDO selyear,${IYR}/${FYR} ${FILE} ${FILE_}

done

else
VAR_LIST="huss mslhf msshf si10"
for VAR in ${VAR_LIST[@]}; do

    # Input files
    FILE="${DIR_OBS}/mon/${VAR}_${DATASET}_${YR}.nc"

    # Output files
    FILE_="${VAR}_${DATASET}_${YR}.nc"

    cp ${FILE} ${FILE_}

done
fi

echo
echo "--------------- THE END POSPROCESSING ----------------"

}
