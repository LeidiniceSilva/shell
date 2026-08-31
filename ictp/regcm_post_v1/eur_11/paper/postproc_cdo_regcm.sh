#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 12, 2024'
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 
{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="EUR-11"

YR="2000-2009"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

VAR_LIST="cli clw" # pr tas clt cl
FOLDER_LIST="NoTo-EUR WSM5-EUR WSM7-EUR WDM7-EUR" # NoTo-EUR WSM5-EUR WSM7-EUR WDM7-EUR

echo
echo "--------------- INIT POSTPROCESSING MODEL ----------------"

for FOLDER in ${FOLDER_LIST[@]}; do

    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_scratch/EUR-11/${FOLDER}"
    DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/postproc/paper"

    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}

    for VAR in ${VAR_LIST[@]}; do
        for YEAR in `seq -w ${IYR} ${FYR}`; do
            for MON in `seq -w 01 12`; do
        	if [ ${VAR} = 'pr' ] || [ ${VAR} = 'tas' ] || [ ${VAR} = 'clt' ]
        	then
		CDO selname,${VAR} ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
        	elif [ ${VAR} = 'cl' ]
        	then
                CDO selname,${VAR} ${DIR_IN}/${EXP}_RAD.${YEAR}${MON}0100_pressure.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
        	else
		CDO selname,${VAR} ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100_pressure.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
        	fi
            done
        done
    
        echo 
        echo "2. Concatenate data"
        CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${FOLDER}_${YR}.nc
        rm ${VAR}_${EXP}_*0100.nc

        echo
        echo "3. Convert unit"
        if [ ${VAR} = 'pr' ]
        then
        CDO -b f32 mulc,3600 ${VAR}_${FOLDER}_${YR}.nc ${VAR}_RegCM5_${FOLDER}_1hr_${YR}.nc
        CDO daysum ${VAR}_RegCM5_${FOLDER}_1hr_${YR}.nc ${VAR}_RegCM5_${FOLDER}_day_${YR}.nc
        elif [ ${VAR} = 'tas' ]
        then
        CDO -b f32 subc,273.15 ${VAR}_${FOLDER}_${YR}.nc ${VAR}_RegCM5_${FOLDER}_1hr_${YR}.nc
	CDO daymean ${VAR}_RegCM5_${FOLDER}_1hr_${YR}.nc ${VAR}_RegCM5_${FOLDER}_day_${YR}.nc
        elif [ ${VAR} = 'clt' ]
        then
        CDO -b f32 divc,100 ${VAR}_${FOLDER}_${YR}.nc ${VAR}_RegCM5_${FOLDER}_1hr_${YR}.nc
	CDO daymean ${VAR}_RegCM5_${FOLDER}_1hr_${YR}.nc ${VAR}_RegCM5_${FOLDER}_day_${YR}.nc
        else
	cp ${VAR}_${FOLDER}_${YR}.nc ${VAR}_RegCM5_${FOLDER}_6hr_${YR}.nc
        CDO daymean ${VAR}_RegCM5_${FOLDER}_6hr_${YR}.nc ${VAR}_RegCM5_${FOLDER}_day_${YR}.nc
        fi

    done
    
    echo 
    echo "4. Delete files"
    rm *_${FOLDER}_${YR}.nc

done

echo
echo "--------------- THE END POSTPROCESSING MODEL ----------------"

}
