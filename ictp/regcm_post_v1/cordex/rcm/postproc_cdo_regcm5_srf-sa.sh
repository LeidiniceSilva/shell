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

YR="2000-2005"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

EXP="SAM-22"
VAR_LIST="rsnl rsns"
#VAR_LIST="clt cll clm clh pr rsnl rsns tas tasmax tasmin"

DIR_IN="/marconi_work/ICT23_ESP/nzazulie/ERA5/NoTo-SouthAmerica"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/CORDEX/post_evaluate"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "1. Select variable"
    for YEAR in `seq -w ${IYR} ${FYR}`; do
        for MON in `seq -w 01 12`; do
            if [ ${VAR} = 'pr'  ] || [ ${VAR} = 'tas'  ] || [ ${VAR} = 'tasmax'  ] || [ ${VAR} = 'tasmin'  ]
            then
            CDO selname,${VAR} ${DIR_IN}/SAM-22_STS.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
            elif [ ${VAR} = 'cll'  ] || [ ${VAR} = 'clm'  ] || [ ${VAR} = 'clh'  ] || [ ${VAR} = 'rsnl'  ] || [ ${VAR} = 'rsns'  ] 
            then
            CDO selname,${VAR} ${DIR_IN}/SAM-22_RAD.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	    else
            CDO selname,${VAR} ${DIR_IN}/SAM-22_SRF.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	    fi
        done
    done
	        
    echo 
    echo "2. Concatenate date"
    CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${EXP}_${YR}.nc

    echo
    echo "3. Convert unit"
    if [ ${VAR} = 'pr'  ]
    then
    CDO -b f32 mulc,86400 ${VAR}_${EXP}_${YR}.nc ${VAR}_${EXP}_RegCM5_day_${YR}.nc
    CDO monmean ${VAR}_${EXP}_RegCM5_day_${YR}.nc ${VAR}_${EXP}_RegCM5_mon_${YR}.nc
    elif [ ${VAR} = 'tas'  ] || [ ${VAR} = 'tasmax'  ] || [ ${VAR} = 'tasmin'  ]
    then
    CDO -b f32 subc,273.15 ${VAR}_${EXP}_${YR}.nc ${VAR}_${EXP}_RegCM5_day_${YR}.nc
    CDO monmean ${VAR}_${EXP}_RegCM5_day_${YR}.nc ${VAR}_${EXP}_RegCM5_mon_${YR}.nc
    else
    CDO daymean ${VAR}_${EXP}_${YR}.nc ${VAR}_${EXP}_RegCM5_day_${YR}.nc
    CDO monmean ${VAR}_${EXP}_RegCM5_day_${YR}.nc ${VAR}_${EXP}_RegCM5_mon_${YR}.nc
    fi

    echo
    echo "4. Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_RegCM5_mon_${YR}.nc ${VAR}_${EXP}_RegCM5_${SEASON}_${YR}.nc
	${BIN}/./regrid ${VAR}_${EXP}_RegCM5_${SEASON}_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil

    done
done

echo 
echo "5. Delete files"
rm *_${EXP}_*0100.nc
rm *_${YR}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
