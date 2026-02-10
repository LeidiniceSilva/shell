#!/bin/bash

#SBATCH -A CMPNS_ictpclim
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the OBS datasets with CDO'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DATASET=$1
EXP="CSAM-3"
YR="2000-2009"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/evaluate/obs"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo 
echo "------------------------------- INIT POSTPROCESSING ${DATASET} -------------------------------"

if [ ${DATASET} == 'CRU' ]
then
VAR_LIST="pre tmp tmx tmn"
for VAR in ${VAR_LIST[@]}; do
    echo
    echo "select years and compute trend"
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cru_ts4.08.1901.2023.${VAR}.dat.nc ${VAR}_${DATASET}_mon_${YR}.nc
    if [ ${VAR} == 'pre' ]
    then
    CDO yearsum ${VAR}_${DATASET}_mon_${YR}.nc ${VAR}_${DATASET}_${YR}.nc
    else
    CDO yearmean ${VAR}_${DATASET}_mon_${YR}.nc ${VAR}_${DATASET}_${YR}.nc
    fi
    CDO trend ${VAR}_${DATASET}_${YR}.nc ${VAR}_${DATASET}_${YR}_atrend.nc ${VAR}_${DATASET}_${YR}_btrend.nc
done

else
VAR_LIST="tp t2m tasmax tasmin"
for VAR in ${VAR_LIST[@]}; do
    echo
    echo "Select date"
    if [ ${VAR} == 'tp' ]
    then
    CDO -b f32 mulc,1000 ${DIR_IN}/${DATASET}/${VAR}_ERA5_1hr_2000-2009.nc ${VAR}_${DATASET}_1hr_${YR}.nc
    CDO yearsum ${VAR}_${DATASET}_1hr_${YR}.nc ${VAR}_${DATASET}_${YR}.nc
    else
    CDO -b f32 subc,273.15 ${DIR_IN}/${DATASET}/${VAR}_ERA5_2000-2009.nc ${VAR}_${DATASET}_mon_${YR}.nc
    CDO yearmean ${VAR}_${DATASET}_mon_${YR}.nc ${VAR}_${DATASET}_${YR}.nc
    fi
    CDO trend ${VAR}_${DATASET}_${YR}.nc ${VAR}_${DATASET}_${YR}_atrend.nc ${VAR}_${DATASET}_${YR}_btrend.nc
done
fi

echo 
echo "------------------------------- THE END POSTPROCESSING ${DATASET} -------------------------------"

}
