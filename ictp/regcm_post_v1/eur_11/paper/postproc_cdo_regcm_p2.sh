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

VAR_LIST="pr uas vas psl clwp clwvi clivi ta ua va wa hus rh cli clw clr cls gra hail ncn ncc ncr"
FOLDER_LIST="NoTo-EUR WSM5-EUR WSM7-EUR WDM7-EUR" 

echo
echo "--------------- INIT POSTPROCESSING MODEL ----------------"

for FOLDER in ${FOLDER_LIST[@]}; do

    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_scratch/EUR-11/${FOLDER}"
    DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/postproc/paper/cyc/RegCM5"

    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}

    for VAR in ${VAR_LIST[@]}; do

        if [[ "${VAR}" == "hail" || "${VAR}" == "gra" ]] && [[ "${FOLDER}" != "WSM7-EUR" && "${FOLDER}" != "WDM7-EUR" ]]; then
            continue
        fi

        if [[ "${VAR}" == "ncc" || "${VAR}" == "ncn" || "${VAR}" == "ncr" ]] && [[ "${FOLDER}" != "WDM7-EUR" ]]; then
            continue
        fi

        for YEAR in `seq -w 2006 2006`; do
            for MON in `seq -w 09 09`; do
                if [ ${VAR} = 'pr' ] || [ ${VAR} = 'uas' ] || [ ${VAR} = 'vas' ] || [ ${VAR} = 'psl' ]
                then
                    CDO selname,${VAR} ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc ${VAR}_${FOLDER}_1hr_${YR}${MON}.nc
                elif [ ${VAR} = 'clwp' ] || [ ${VAR} = 'clwvi' ] || [ ${VAR} = 'clivi' ]
                then
                    CDO selname,${VAR} ${DIR_IN}/${EXP}_RAD.${YEAR}${MON}0100_pressure.nc ${VAR}_${FOLDER}_6hr_${YR}${MON}.nc
                else
                    CDO selname,${VAR} ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100_pressure.nc ${VAR}_${FOLDER}_1hr_${YR}${MON}.nc
                fi
            done
        done
    done
done

echo
echo "--------------- THE END POSTPROCESSING MODEL ----------------"

}

