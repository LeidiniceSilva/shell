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
#__date__        = 'Mar 12, 2024'
#__description__ = 'Calculate the freq/int of OBS datasets with CDO'

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DATASET=$1
EXP="EUR-11"

YR="2000-2009"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/postproc/obs"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo 
echo "------------------------------- INIT POSTPROCESSING ${DATASET} -------------------------------"

if [ ${DATASET} == 'EOBS' ]
then
VAR="rr"
   
echo
echo "1. Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/rr.nc ${VAR}_${DATASET}_${EXP}_${YR}.nc

echo
echo "2. Frequency and intensity by season"
for SEASON in ${SEASON_LIST[@]}; do
    CDO selseas,${SEASON} ${VAR}_${DATASET}_${EXP}_${YR}.nc ${VAR}_${DATASET}_${EXP}_${SEASON}_${YR}.nc
    
    CDO mulc,100 -histfreq,1,100000 ${VAR}_${DATASET}_${EXP}_${SEASON}_${YR}.nc ${VAR}_freq_${DATASET}_${EXP}_${SEASON}_${YR}.nc
    ${BIN}/./regrid ${VAR}_freq_${DATASET}_${EXP}_${SEASON}_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil

    CDO histmean,1,100000 ${VAR}_${DATASET}_${EXP}_${SEASON}_${YR}.nc ${VAR}_int_${DATASET}_${EXP}_${SEASON}_${YR}.nc
    ${BIN}/./regrid ${VAR}_int_${DATASET}_${EXP}_${SEASON}_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
done

else
VAR="tp"

echo
echo "1. Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/tp_ERA5_1hr_2000-2009.nc ${VAR}_${DATASET}_1hr_${YR}.nc
CDO daysum ${VAR}_${DATASET}_1hr_${YR}.nc ${VAR}_${DATASET}_${YR}.nc
CDO mulc,1000 ${VAR}_${DATASET}_${YR}.nc ${VAR}_${DATASET}_${EXP}_${YR}.nc 

echo
echo "2. Frequency and intensity by season"
for SEASON in ${SEASON_LIST[@]}; do
    CDO selseas,${SEASON} ${VAR}_${DATASET}_${EXP}_${YR}.nc  ${VAR}_${DATASET}_${EXP}_${SEASON}_${YR}.nc

    CDO mulc,100 -histfreq,1,100000 ${VAR}_${DATASET}_${EXP}_${SEASON}_${YR}.nc ${VAR}_freq_${DATASET}_${EXP}_${SEASON}_${YR}.nc
    ${BIN}/./regrid ${VAR}_freq_${DATASET}_${EXP}_${SEASON}_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil

    CDO histmean,1,100000 ${VAR}_${DATASET}_${EXP}_${SEASON}_${YR}.nc ${VAR}_int_${DATASET}_${EXP}_${SEASON}_${YR}.nc
    ${BIN}/./regrid ${VAR}_int_${DATASET}_${EXP}_${SEASON}_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
done
fi

echo 
echo "Delete files"
rm *_${YR}.nc

echo
echo "------------------------------- THE END POSTPROCESSING ${DATASET} -------------------------------"

}
