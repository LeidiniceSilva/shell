#!/bin/bash

#SBATCH -A ICT23_ESP_1
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 12, 2024'
#__description__ = 'Posprocessing the OBS datasets with CDO'

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DATASET=$1
DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS/${DATASET}"

echo
cd ${DIR_IN}
echo ${DIR_IN}

echo
echo "------------------------------- INIT POSTPROCESSING ${DATASET} -------------------------------"

if [ ${DATASET} == 'MSWEP' ]
then
FILE_OUT=mswep.day.1979-2020.nc
FILE_IN=$( eval ls ????.nc )
[[ ! -f $FILE_OUT ]] && CDO mergetime $FILE_IN $FILE_OUT
fi

echo
echo "------------------------------- THE END POSTPROCESSING ${DATASET} -------------------------------"

}
