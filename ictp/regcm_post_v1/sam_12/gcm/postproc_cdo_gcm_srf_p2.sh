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

MDL_LIST="EC-Earth3-Veg MPI-ESM1-2-HR NorESM2-MM" 
VAR="pr"
EXP="SAM-12"

YR="1971-1972"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/${EXP}/postproc/gcm"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_IN}
echo ${DIR_IN}

echo
echo "--------------- INIT POSTPROCESSING MODEL ----------------"

for MDL in ${MDL_LIST[@]}; do

    if [ ${MDL} == 'EC-Earth3-Veg' ]
    then
    MEMBER="r1i1p1f1_gr"
    else
    MEMBER="r1i1p1f1_gn"
    fi

    CDO selyear,${IYR}/${FYR} ${VAR}_day_${MDL}_historical_${MEMBER}_19700101-19791231.nc ${VAR}_${MDL}_day_${YR}.nc
    CDO -b f32 mulc,86400 ${VAR}_${MDL}_day_${YR}.nc ${VAR}_${EXP}_${MDL}_day_${YR}.nc

    CDO timmin ${VAR}_${EXP}_${MDL}_day_${YR}.nc ${VAR}_${EXP}_${MDL}_day_${YR}_min.nc
    CDO timmax ${VAR}_${EXP}_${MDL}_day_${YR}.nc ${VAR}_${EXP}_${MDL}_day_${YR}_max.nc
    CDO timpctl,99 ${VAR}_${EXP}_${MDL}_day_${YR}.nc ${VAR}_${EXP}_${MDL}_day_${YR}_min.nc ${VAR}_${EXP}_${MDL}_day_${YR}_max.nc p99_${EXP}_${MDL}_${YR}.nc
    ${BIN}/./regrid p99_${EXP}_${MDL}_${YR}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil

    for SEASON in ${SEASON_LIST[@]}; do
	CDO selseas,${SEASON} ${VAR}_${EXP}_${MDL}_day_${YR}.nc ${VAR}_${EXP}_${MDL}_${SEASON}_${YR}.nc

	CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_${MDL}_${SEASON}_${YR}.nc ${VAR}_freq_${EXP}_${MDL}_${SEASON}_${YR}.nc
	${BIN}/./regrid ${VAR}_freq_${EXP}_${MDL}_${SEASON}_${YR}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil

	CDO histmean,1,100000 ${VAR}_${EXP}_${MDL}_${SEASON}_${YR}.nc ${VAR}_int_${EXP}_${MDL}_${SEASON}_${YR}.nc
	${BIN}/./regrid ${VAR}_int_${EXP}_${MDL}_${SEASON}_${YR}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    done

done

echo
echo "--------------- THE END POSTPROCESSING MODEL ----------------"

}
