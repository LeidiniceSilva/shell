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
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DATASET=$1

YR="1999-2009"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

DIR_IN="/leonardo_work/ICT24_ESP/OBS/${DATASET}"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS/${DATASET}"

echo
echo "------------------------------- INIT POSTPROCESSING ${DATASET} -------------------------------"

if [ ${DATASET} == 'CPC' ]
then
VAR_LIST="precip tmax tmin"
for VAR in ${VAR_LIST[@]}; do
    FILE_OUT=${VAR}.cpc.day.1979-2024.nc
    if [ ${VAR} == 'precip' ]
    then
    FILE_IN=$( eval ls ${DIR_IN}/${VAR}/${VAR}.????.nc )
    else
    FILE_IN=$( eval ls ${DIR_IN}/temp/${VAR}.????.nc )
    fi
    [[ ! -f $FILE_OUT ]] && CDO mergetime $FILE_IN ${DIR_OUT}/$FILE_OUT
done

elif [ ${DATASET} == 'ERA5' ]
then
VAR_LIST="pr"
#VAR_LIST="pr tas cll clm clh clt clfrac clice clliq clivi qhum rhum uwnd vwnd evpot roff"

for VAR in ${VAR_LIST[@]}; do
    for YEAR in `seq -w ${IYR} ${FYR}`; do
        if [ ${VAR} == 'pr' ]
        then
        FILE_OUT=${DIR_OUT}/${VAR}_${YEAR}.nc
        FILE_IN=$( eval ls ${DIR_IN}/hourly/${VAR}_${YEAR}_??.nc )
        [[ ! -f $FILE_OUT ]] && CDO -b f32 mergetime $FILE_IN $FILE_OUT
        else
        FILE_OUT=${DIR_OUT}/${VAR}_${YEAR}.nc
        FILE_IN=$( eval ls ${DIR_IN}/monthly/${YEAR}/${VAR}_${YEAR}_??.nc )
        [[ ! -f $FILE_OUT ]] && CDO -b f32 mergetime $FILE_IN $FILE_OUT
        fi
    done

    if [ ${VAR} == 'pr' ]
    then
    FILE_OUT_x=${DIR_OUT}/${VAR}_${DATASET}_1hr_${YR}.nc
    else
    FILE_OUT_x=${DIR_OUT}/${VAR}_${DATASET}_${YR}.nc
    fi
    FILE_OUT_y=$( eval ls ${DIR_OUT}/${VAR}_????.nc )
    [[ ! -f $FILE_OUT_x ]] && CDO -b f32 mergetime $FILE_OUT_y $FILE_OUT_x
    rm ${DIR_OUT}/${VAR}_????.nc
done

else
FILE_OUT=mswep.day.1979-2020.nc
FILE_IN=$( eval ls ????.nc )
[[ ! -f $FILE_OUT ]] && CDO mergetime ${DIR_IN}/$FILE_IN ${DIR_OUT}/$FILE_OUT
fi

echo
echo "------------------------------- THE END POSTPROCESSING ${DATASET} -------------------------------"

}
