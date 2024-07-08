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
#__date__        = 'Jan 02, 2024'
#__description__ = 'Posprocessing the RegCM5 output with CDO'

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="SAM-3km-cyclone"
YEAR="2023"
VAR_LIST="hus pr psl sfcWind ta tas ua uas va vas wa"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km-cyclone/NoTo-SAM"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km-cyclone/post"
DIR_BIN="/marconi/home/userexternal/ggiulian/binaries_5.0"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "1. Select variable: ${VAR}"
    for MON in `seq -w 06 07`; do
    	if [ ${VAR} = hus  ]
	then
	CDO selname,${VAR} ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	${DIR_BIN}/./sigma2pNETCDF4_HDF5_CLM45_SKL SAM_3km_cyclone_CP_RegCM5_ERA5.in ${VAR}_${EXP}_${YEAR}${MON}0100.nc
    	elif [ ${VAR} = ta  ]
	then
	CDO selname,${VAR} ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	${DIR_BIN}/./sigma2pNETCDF4_HDF5_CLM45_SKL SAM_3km_cyclone_CP_RegCM5_ERA5.in ${VAR}_${EXP}_${YEAR}${MON}0100.nc
    	elif [ ${VAR} = ua  ]
	then
	CDO selname,${VAR} ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	${DIR_BIN}/./sigma2pNETCDF4_HDF5_CLM45_SKL SAM_3km_cyclone_CP_RegCM5_ERA5.in ${VAR}_${EXP}_${YEAR}${MON}0100.nc
    	elif [ ${VAR} = va  ]
	then
	CDO selname,${VAR} ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	${DIR_BIN}/./sigma2pNETCDF4_HDF5_CLM45_SKL SAM_3km_cyclone_CP_RegCM5_ERA5.in ${VAR}_${EXP}_${YEAR}${MON}0100.nc
    	elif [ ${VAR} = wa  ]
	then
	CDO selname,${VAR} ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	${DIR_BIN}/./sigma2pNETCDF4_HDF5_CLM45_SKL SAM_3km_cyclone_CP_RegCM5_ERA5.in ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	else
	CDO selname,${VAR} ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	fi
    done   
done


echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
