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

YR="1970-1971"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

if [ ${INST} == 'RegCM5-ERA5_ICTP' ]
then
DIR_IN="/leonardo/home/userexternal/mdasilva/reg-nor"
else
DIR_IN="/leonardo_work/ICT25_ESP/nzazulie/SAM-12/ERA5/NoTo-SouthAmerica"
fi
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
    for YEAR in `seq -w ${IYR} ${FYR}`; do
        for MON in `seq -w 01 12`; do
            CDO selname,${VAR} ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc  
	done
    done

    echo 
    echo "Concatenate data"
    CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${EXP}_${INST}_${YR}.nc

    if [ ${VAR} == 'pr' ]
    then
    CDO -b f32 mulc,86400 ${VAR}_${EXP}_${INST}_${YR}.nc ${VAR}_${EXP}_${INST}_day_${YR}.nc
    else 
    CDO -b f32 subc,273.15 ${VAR}_${EXP}_${INST}_${YR}.nc ${VAR}_${EXP}_${INST}_day_${YR}.nc
    fi
    CDO monmean ${VAR}_${EXP}_${INST}_day_${YR}.nc ${VAR}_${EXP}_${INST}_mon_${YR}.nc

    echo
    echo "Seasonal avg and Regrid"
    for SEASON in ${SEASON_LIST[@]}; do
        CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${INST}_mon_${YR}.nc ${VAR}_${EXP}_${INST}_${SEASON}_${YR}.nc
	${BIN}/./regrid ${VAR}_${EXP}_${FOLDER}_RegCM5_${SEASON}_${YR}.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil
    done
    
    echo 
    echo "Delete files"
    rm *0100.nc
    rm *${YR}.nc

done

echo
echo "--------------- THE END POSTPROCESSING MODEL ----------------"

}
