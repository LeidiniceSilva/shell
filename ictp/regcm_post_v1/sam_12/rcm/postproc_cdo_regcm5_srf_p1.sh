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

INST="RegCM5-Nor_USP" # RegCM5-Nor_USP
EXP="SAM-12"

YR="1971-1972"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/${EXP}/postproc/rcm"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSTPROCESSING MODEL ----------------"

echo 
echo "Select variables"    
VAR_LIST="pr tas"
for VAR in ${VAR_LIST[@]}; do

    if [ ${INST} == 'RegCM5-Nor_USP' ]; then
    DIR_IN="/leonardo/home/userexternal/mdasilva/reg-nor"
    else
    DIR_IN="/leonardo_work/ICT25_ESP/nzazulie/CORDEX/CORDEX-CMIP6/DD/SAM-12/ICTP/ERA5/evaluation/r0i0p0f0/RegCM5-0/v1-r1/day/${VAR}"
    fi

    if [ ${INST} = "RegCM5-Nor_USP" ]; then
    for YEAR in `seq -w ${IYR} ${FYR}`; do
        for MON in `seq -w 01 12`; do
            CDO selname,${VAR} ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}01.nc 
	done
    done
    CDO mergetime ${VAR}_${EXP}_*01.nc ${VAR}_${EXP}_${INST}_${YR}.nc
    else
    CDO mergetime ${DIR_IN}/${VAR}_${EXP}_*_${IYR}*.nc ${DIR_IN}/${VAR}_${EXP}_*_${FYR}*.nc ${VAR}_${EXP}_${INST}_${YR}.nc 
    fi

    if [ ${VAR} == 'pr' ]
    then
    CDO -b f32 mulc,86400 ${VAR}_${EXP}_${INST}_${YR}.nc ${VAR}_${EXP}_${INST}_day_${YR}.nc
    else 
    CDO -b f32 subc,273.15 ${VAR}_${EXP}_${INST}_${YR}.nc ${VAR}_${EXP}_${INST}_day_${YR}.nc
    fi
    CDO monmean ${VAR}_${EXP}_${INST}_day_${YR}.nc ${VAR}_${EXP}_${INST}_mon_${YR}.nc

    for SEASON in ${SEASON_LIST[@]}; do
        CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${INST}_mon_${YR}.nc ${VAR}_${EXP}_${INST}_${SEASON}_${YR}.nc
	${BIN}/./regrid ${VAR}_${EXP}_${INST}_${SEASON}_${YR}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
    done

done

echo
echo "--------------- THE END POSTPROCESSING MODEL ----------------"

}
