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
#__date__        = 'Jan 10, 2026'
#__description__ = 'Posprocessing the RegCM5 output with CDO'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="2018-2021"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

EXP="SAM-3km"
VAR_LIST="hfss hfls rsnl rsns"
#VAR_LIST="pr tas tasmax tasmin mrsos hfss hfls rsnl rsns hus ua va wa"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_scratch/SAM-3km/output"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/drought/rcm"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

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
            if [ ${VAR} = 'pr'  ] || [ ${VAR} = 'tas'  ] || [ ${VAR} = 'tasmax'  ] || [ ${VAR} = 'tasmin'  ] 
            then
            CDO selname,${VAR} ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
            elif [ ${VAR} = 'hus'  ] || [ ${VAR} = 'ua'  ] || [ ${VAR} = 'va'  ] || [ ${VAR} = 'wa'  ] 
            then
            CDO selname,${VAR} ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100_pressure.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
            else
            CDO selname,${VAR} ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	    fi
	    ${BIN}/./regrid ${VAR}_${EXP}_${YEAR}${MON}0100.nc -35.70235,-11.25009,0.22 -78.66277,-35.48362,0.22 bil
        done
    done
    
    echo 
    echo "Concatenate date"
    CDO mergetime ${VAR}_${EXP}_*0100_lonlat.nc ${VAR}_${EXP}_RegCM5_${YR}_lonlat.nc

    echo
    echo "Convert unit"
    if [ ${VAR} = 'pr'  ] 
    then
    CDO -b f32 mulc,86400 ${VAR}_${EXP}_RegCM5_${YR}_lonlat.nc ${VAR}_${EXP}_RegCM5_day_${YR}_lonlat.nc
    CDO monmean ${VAR}_${EXP}_RegCM5_day_${YR}_lonlat.nc ${VAR}_${EXP}_RegCM5_mon_${YR}_lonlat.nc
    elif [ ${VAR} = 'tas'  ] || [ ${VAR} = 'tasmax'  ] || [ ${VAR} = 'tasmin'  ] 
    then
    CDO -b f32 subc,273.15 ${VAR}_${EXP}_RegCM5_${YR}_lonlat.nc ${VAR}_${EXP}_RegCM5_day_${YR}_lonlat.nc
    CDO monmean ${VAR}_${EXP}_RegCM5_${YR}_lonlat.nc ${VAR}_${EXP}_RegCM5_mon_${YR}_lonlat.nc
    else
    CDO daymean ${VAR}_${EXP}_RegCM5_${YR}_lonlat.nc ${VAR}_${EXP}_RegCM5_day_${YR}_lonlat.nc
    CDO monmean ${VAR}_${EXP}_RegCM5_day_${YR}_lonlat.nc ${VAR}_${EXP}_RegCM5_mon_${YR}.nc
    fi
  
    echo 
    echo "Delete files"
    rm ${VAR}_${EXP}_*0100.nc
    rm ${VAR}_${EXP}_RegCM5_${YR}_lonlat.nc

done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
