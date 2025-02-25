#!/bin/bash

#SBATCH -A ICT23_ESP_1
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
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="2018-2018"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

EXP="SAM-3km"
VAR_LIST="cl cli clw hus ua va"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/output"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/evaluate/rcm"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "Select variable: ${VAR}"
    for YEAR in `seq -w ${IYR} ${FYR}`; do
        for MON in `seq -w 01 12`; do
            if [ ${VAR} = 'cl'  ]
            then
            CDO selname,${VAR} ${DIR_IN}/${EXP}_RAD.${YEAR}${MON}0100_pressure.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	    CDO monmean ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_mon_${YEAR}${MON}0100.nc
            else
            CDO selname,${VAR} ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100_pressure.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	    CDO monmean ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_mon_${YEAR}${MON}0100.nc
	    fi   
        done
    done	

    echo 
    echo "Concatenate date: ${YR}"
    CDO mergetime ${VAR}_${EXP}_mon_*0100.nc ${VAR}_${EXP}_RegCM5_mon_${YR}.nc 

    echo 
    echo "Regrid output"
    ${BIN}/./regrid ${VAR}_${EXP}_RegCM5_mon_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    
    echo
    echo "Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
        CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_RegCM5_mon_${YR}_lonlat.nc ${VAR}_${EXP}_RegCM5_${SEASON}_${YR}_lonlat.nc  
    done   
done

echo 
echo "Delete files"
rm *_${EXP}_*0100.nc
rm *_${YR}.nc
    
echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
