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

YR="2006"

VAR_LIST="ta" # pr uas vas psl cli clw wa hus rh ta clwp clwvi clivi 
FOLDER_LIST="NoTo-EUR WSM5-EUR WSM7-EUR WDM7-EUR" # NoTo-EUR WSM5-EUR WSM7-EUR WDM7-EUR

echo
echo "--------------- INIT POSTPROCESSING MODEL ----------------"

for FOLDER in ${FOLDER_LIST[@]}; do

    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_scratch/EUR-11/${FOLDER}"
    DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/postproc/paper/cyc"

    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}

    for VAR in ${VAR_LIST[@]}; do
        for YEAR in `seq -w 2006 2006`; do
            for MON in `seq -w 09 09`; do
        	if [ ${VAR} = 'pr' ] || [ ${VAR} = 'uas' ] || [ ${VAR} = 'vas' ] || [ ${VAR} = 'psl' ]
        	then
		CDO selname,${VAR} ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
		mv ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${FOLDER}_1hr_${YR}09.nc
        	elif [ ${VAR} = 'ta' ] || [ ${VAR} = 'cli' ] || [ ${VAR} = 'clw' ] || [ ${VAR} = 'wa' ] || [ ${VAR} = 'hus' ] || [ ${VAR} = 'rh' ]
        	then
                CDO selname,${VAR} ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100_pressure.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
		mv ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${FOLDER}_1hr_${YR}09.nc
        	else
		CDO selname,${VAR} ${DIR_IN}/${EXP}_RAD.${YEAR}${MON}0100_pressure.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
		mv ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${FOLDER}_6hr_${YR}09.nc
        	fi
            done
        done
    done
done

echo
echo "--------------- THE END POSTPROCESSING MODEL ----------------"

}
