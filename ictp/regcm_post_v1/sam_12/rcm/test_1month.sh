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
#__date__        = 'Jan 30, 2026'
#__description__ = 'Posprocessing the RegCM5 output with CDO'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

INST="RegCM5-ERA5_ICTP"
EXP="SAM-12"

YEAR="1970"
MON="01"

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/${EXP}/postproc/rcm"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo 
echo "Select variables"
VAR_LIST="pr tas"
for VAR in ${VAR_LIST[@]}; do

    if [ ${INST} == 'RegCM5-ERA5_USP' ]; then
    DIR_IN="/leonardo/home/userexternal/mdasilva/reg-era5"
    else
    DIR_IN="/leonardo_work/ICT25_ESP/nzazulie/CORDEX/CORDEX-CMIP6/DD/SAM-12/ICTP/ERA5/evaluation/r0i0p0f0/RegCM5-0/v1-r1/day/${VAR}"
    fi

    if [ "${INST}" = "RegCM5-ERA5_USP" ]; then
    if [ ${VAR} == 'pr' ]; then
    CDO -b f32 mulc,3600 ${DIR_IN}/pr_SAM-12_SRF.1970020100.nc ${VAR}_${EXP}_${INST}_${YEAR}${MON}01.nc
    CDO daysum ${VAR}_${EXP}_${INST}_${YEAR}${MON}01.nc ${VAR}_${EXP}_${INST}_day_${YEAR}${MON}.nc
    CDO monmean ${VAR}_${EXP}_${INST}_day_${YEAR}${MON}.nc ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc
    CDO timmin ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc ${VAR}_${EXP}_${INST}_${YEAR}${MON}_min.nc
    CDO timmax ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc ${VAR}_${EXP}_${INST}_${YEAR}${MON}_max.nc
    CDO timpctl,99 ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc ${VAR}_${EXP}_${INST}_${YEAR}${MON}_min.nc ${VAR}_${EXP}_${INST}_${YEAR}${MON}_max.nc p99_${EXP}_${INST}_${YEAR}${MON}.nc
    CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc ${VAR}_freq_${EXP}_${INST}_${YEAR}${MON}.nc
    CDO histmean,1,100000 ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc ${VAR}_int_${EXP}_${INST}_${YEAR}${MON}.nc
    ${BIN}/./regrid ${VAR}_${EXP}_${INST}_day_${YEAR}${MON}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    ${BIN}/./regrid ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    ${BIN}/./regrid p99_${EXP}_${INST}_${YEAR}${MON}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    ${BIN}/./regrid ${VAR}_freq_${EXP}_${INST}_${YEAR}${MON}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    ${BIN}/./regrid ${VAR}_int_${EXP}_${INST}_${YEAR}${MON}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    else
    CDO -b f32 subc,273.15 ${DIR_IN}/tas_SAM-12_SRF.1970020100.nc ${VAR}_${EXP}_${INST}_${YEAR}${MON}01.nc 
    CDO monmean ${VAR}_${EXP}_${INST}_${YEAR}${MON}01.nc ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc 
    ${BIN}/./regrid ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    fi

    else
    if [ ${VAR} == 'pr' ]
    then
    CDO -b f32 mulc,86400 ${DIR_IN}/pr_SAM-12_ERA5_evaluation_r0i0p0f0_ICTP_RegCM5-0_v1-r1_day_19700101-19700131.nc ${VAR}_${EXP}_${INST}_day_${YEAR}${MON}.nc 
    CDO monmean ${VAR}_${EXP}_${INST}_day_${YEAR}${MON}.nc ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc
    CDO timmin ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc ${VAR}_${EXP}_${INST}_${YEAR}${MON}_min.nc
    CDO timmax ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc ${VAR}_${EXP}_${INST}_${YEAR}${MON}_max.nc
    CDO timpctl,99 ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc ${VAR}_${EXP}_${INST}_${YEAR}${MON}_min.nc ${VAR}_${EXP}_${INST}_${YEAR}${MON}_max.nc p99_${EXP}_${INST}_${YEAR}${MON}.nc
    CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc ${VAR}_freq_${EXP}_${INST}_${YEAR}${MON}.nc
    CDO histmean,1,100000 ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc ${VAR}_int_${EXP}_${INST}_${YEAR}${MON}.nc
    ${BIN}/./regrid ${VAR}_${EXP}_${INST}_day_${YEAR}${MON}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    ${BIN}/./regrid ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    ${BIN}/./regrid p99_${EXP}_${INST}_${YEAR}${MON}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    ${BIN}/./regrid ${VAR}_freq_${EXP}_${INST}_${YEAR}${MON}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    ${BIN}/./regrid ${VAR}_int_${EXP}_${INST}_${YEAR}${MON}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    else
    CDO -b f32 subc,273.15 ${DIR_IN}/tas_SAM-12_ERA5_evaluation_r0i0p0f0_ICTP_RegCM5-0_v1-r1_day_19700101-19700131.nc ${VAR}_${EXP}_${INST}_day_${YEAR}${MON}.nc
    CDO monmean ${VAR}_${EXP}_${INST}_day_${YEAR}${MON}.nc ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc 
    ${BIN}/./regrid ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    fi
    fi

done

echo 
echo "Delete files"
rm *01.nc
rm *min.nc
rm *max.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
