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
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 
{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

VAR="pr"
FREQ="1hr"
DOMAIN="CSAM-3"
EXP="ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1"

YR="2000-2009"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/ERA5/ERA5-CSAM/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/${FREQ}/${VAR}"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/evaluate/rcm"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo 
echo "Concatenate date: ${YR}"
CDO mergetime ${DIR_IN}/${VAR}_${DOMAIN}_${EXP}_${FREQ}_*.nc ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc
    
echo
echo "Convert unit"
CDO -b f32 mulc,3600 ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_${FREQ}_${YR}.nc

echo
echo "Hourly mean"
for HR in `seq -w 00 23`; do
    CDO selhour,${HR} ${VAR}_${DOMAIN}_RegCM5_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_${HR}hr_${YR}.nc
    CDO timmean ${VAR}_${DOMAIN}_RegCM5_${HR}hr_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_${HR}hr_${YR}_timmean.nc
done
    
echo
echo "Diurnal cycle"
CDO mergetime ${VAR}_${DOMAIN}_RegCM5_*_${YR}_timmean.nc ${VAR}_${DOMAIN}_RegCM5_diurnal_cycle_${YR}.nc
    
echo
echo "Regrid output"
${BIN}/./regrid ${VAR}_${DOMAIN}_RegCM5_diurnal_cycle_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

echo 
echo "Delete files"
rm ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc
rm ${VAR}_${DOMAIN}_RegCM5_${FREQ}_${YR}.nc
rm ${VAR}_${DOMAIN}_RegCM5_*hr_${YR}.nc
rm ${VAR}_${DOMAIN}_RegCM5_*hr_${YR}_timmean.nc
rm ${VAR}_${DOMAIN}_RegCM5_diurnal_cycle_${YR}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}



