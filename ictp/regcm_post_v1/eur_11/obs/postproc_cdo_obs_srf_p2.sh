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
#__description__ = 'Posprocessing the OBS datasets with CDO'

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

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/postproc/obs"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo 
echo "------------------------------- INIT POSTPROCESSING ${DATASET} -------------------------------"

VAR="tp"

echo
echo "1. Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_1hr_2000-2009.nc ${VAR}_${DATASET}_1hr_${YR}.nc
CDO mulc,1000 ${VAR}_${DATASET}_1hr_${YR}.nc ${VAR}_${DATASET}_${EXP}_1hr_${YR}.nc

echo
echo "2. Hourly mean"
for HR in `seq -w 00 23`; do
    CDO selhour,${HR} ${VAR}_${DATASET}_${EXP}_1hr_${YR}.nc ${VAR}_${DATASET}_${EXP}_${HR}hr_${YR}.nc
    CDO timmean ${VAR}_${DATASET}_${EXP}_${HR}hr_${YR}.nc ${VAR}_${DATASET}_${EXP}_${HR}hr_${YR}_timmean.nc
done

echo
echo "3. Diurnal cycle"
CDO mergetime ${VAR}_${DATASET}_${EXP}_*_${YR}_timmean.nc ${VAR}_${DATASET}_${EXP}_diurnal_cycle_${YR}.nc

echo
echo "4. Regrid variable"
${BIN}/./regrid ${VAR}_${DATASET}_${EXP}_diurnal_cycle_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
CDO sellonlatbox,1,16,40,50 ${VAR}_${DATASET}_${EXP}_diurnal_cycle_${YR}_lonlat.nc ${VAR}_${DATASET}_${EXP}-FPS_diurnal_cycle_${YR}_lonlat.nc

echo
echo "Delete files"
rm *_${YR}.nc
rm *_timmean.nc

echo
echo "------------------------------- END POSTPROCESSING ${DATASET} -------------------------------"

}
