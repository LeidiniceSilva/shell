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

if [ ${DATASET} == 'CMORPH' ]
then
VAR="cmorph"

echo
echo "Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cmorph_CSAM-3_CMORPH_1hr_2000-2009.nc ${VAR}_${EXP}_${DATASET}_${YR}.nc

echo
echo "Hourly mean"
for HR in `seq -w 00 23`; do
    CDO selhour,${HR} ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${HR}hr_${YR}.nc
    CDO timmean ${VAR}_${EXP}_${DATASET}_${HR}hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_${HR}hr_${YR}_timmean.nc
done

echo
echo "Diurnal cycle"
CDO mergetime ${VAR}_${EXP}_${DATASET}_*hr_${YR}_timmean.nc ${VAR}_${EXP}_${DATASET}_diurnal_cycle_${YR}.nc

echo
echo "Regrid output"
${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_diurnal_cycle_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

else
VAR="tp"

echo
echo "Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/tp_ERA5_1hr_2000-2009.nc ${VAR}_${DATASET}_${YR}.nc 

echo
echo "Convert unit"
CDO -b f32 mulc,1000 ${VAR}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${YR}.nc    

echo
echo "Hourly mean"
for HR in `seq -w 00 23`; do
    CDO selhour,${HR} ${VAR}_${EXP}_${DATASET}_${YR}.nc ${VAR}_${EXP}_${DATASET}_${HR}hr_${YR}.nc
    CDO timmean ${VAR}_${EXP}_${DATASET}_${HR}hr_${YR}.nc ${VAR}_${EXP}_${DATASET}_${HR}hr_${YR}_timmean.nc
done

echo
echo "Diurnal cycle"
CDO mergetime ${VAR}_${EXP}_${DATASET}_*hr_${YR}_timmean.nc ${VAR}_${EXP}_${DATASET}_diurnal_cycle_${YR}.nc  

echo
echo "Regrid output"
${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_diurnal_cycle_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
fi
 
echo 
echo "Delete files"
rm *_${YR}.nc
rm *_${YR}_timmean.nc

echo 
echo "------------------------------- THE END POSTPROCESSING ${DATASET} -------------------------------"

}
