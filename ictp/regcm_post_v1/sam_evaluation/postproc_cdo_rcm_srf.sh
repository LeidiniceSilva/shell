#!/bin/bash

#SBATCH -N 1 
#SBATCH -t 24:00:00
#SBATCH -A ICT23_ESP
#SBATCH --qos=qos_prio
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p skl_usr_prod

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 
{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="2005-2009"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

EXP="SAM-22"
VAR_LIST="pr"

DIR_IN="/marconi_work/ICT23_ESP/nzazulie/ERA5/NoTo-SouthAmerica"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SA_evaluation/SAM-22"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "Select variable"
    for YEAR in `seq -w ${IYR} ${FYR}`; do
        for MON in `seq -w 01 12`; do
            CDO selname,${VAR} ${DIR_IN}/SAM-22_SHF.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
        done
    done
	        
    echo 
    echo "Concatenate date"
    CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${EXP}_${YR}.nc

    echo
    echo "Convert unit"
    CDO -b f32 mulc,3600 ${VAR}_${EXP}_${YR}.nc ${VAR}_${EXP}_RegCM5_1hr_${YR}.nc
    CDO daysum ${VAR}_${EXP}_RegCM5_1hr_${YR}.nc ${VAR}_${EXP}_RegCM5_day_${YR}.nc
    CDO monmean ${VAR}_${EXP}_RegCM5_day_${YR}.nc ${VAR}_${EXP}_RegCM5_mon_${YR}.nc

    echo
    echo "Regrid"
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_1hr_${YR}.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_day_${YR}.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_mon_${YR}.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil

    echo
    echo "Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_RegCM5_mon_${YR}_lonlat.nc ${VAR}_${EXP}_RegCM5_${SEASON}_${YR}_lonlat.nc
    done
    
done

echo 
echo "5. Delete files"
rm *0100.nc
rm *${YR}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
