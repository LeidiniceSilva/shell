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
#__date__        = 'Jul 28, 2026'
#__description__ = 'Posprocessing the RegCM5 output with CDO'

source $HOME/modules_new

export REMAP_EXTRAPOLATE=off
export SKIP_SAME_TIME=1

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP=$1
DOMAIN="CSAM-3"

VAR_LIST="hfls hfss" 

FREQ="day"
YR="2000-2009"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="ANN DJF MAM JJA SON"

DATASET="ERA5"
DIR_OBS="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS/${DATASET}/mon"

GRIDDES="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts_regcm"

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/urban/paper"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING ----------------"

for VAR in ${VAR_LIST[@]}; do

    if [ ${VAR} == "hfls" ]; then
        VAR_OBS="mslhf"
    elif [ ${VAR} == "hfss" ]; then
        VAR_OBS="msshf"
    elif [ ${VAR} == "sfcWind" ]; then
        VAR_OBS="si10"
    fi

    # Input files
    REGCM_FILE="${VAR}_${DOMAIN}_RegCM5-ERA5_${EXP}_${FREQ}_${YR}.nc"
    OBS_FILE="${DIR_OBS}/${VAR_OBS}_${DATASET}_${YR}.nc"

    if [ ! -f ${REGCM_FILE} ]; then
        echo "ERROR: RegCM file not found: ${REGCM_FILE}"
        exit 1
    fi
    if [ ! -f ${OBS_FILE} ]; then
        echo "ERROR: OBS file not found: ${OBS_FILE}"
        exit 1
    fi

for SEAS in ${SEASON_LIST[@]}; do
        
        # Postproc RegCM & CPC based on season/ANN
        REGCM_FILE_AVG="${VAR}_${DOMAIN}_RegCM5-ERA5_${EXP}_${SEAS}_${YR}.nc"
        OBS_FILE_AVG="${VAR_OBS}_${DATASET}_${SEAS}_${YR}.nc"

        if [ ${SEAS} == "ANN" ]; then
            CDO timmean ${REGCM_FILE} ${REGCM_FILE_AVG}
            CDO timmean ${OBS_FILE} ${OBS_FILE_AVG}
        else
            [[ ${SEAS} = DJF ]] && MONS="12,01,02" 
            [[ ${SEAS} = MAM ]] && MONS="03,04,05"
            [[ ${SEAS} = JJA ]] && MONS="06,07,08" 
            [[ ${SEAS} = SON ]] && MONS="09,10,11"

            CDO timmean -selmonth,${MONS} ${REGCM_FILE} ${REGCM_FILE_AVG}
            CDO timmean -selmonth,${MONS} ${OBS_FILE} ${OBS_FILE_AVG}
        fi

        RES_OBS="0.25"
        REGCM_FILE_REGRID="${VAR}_${DOMAIN}_RegCM5-ERA5_${EXP}_${SEAS}_${YR}_${RES_OBS}.nc"
        OBS_FILE_REGRID="${VAR_OBS}_${DOMAIN}_${DATASET}_${SEAS}_${YR}_${RES_OBS}.nc"

        # Create grid
        GRID=${DOMAIN}_CPC.grid
        if [ ! -f ${GRID} ]; then
            python3 ${GRIDDES}/griddes_ll.py ${REGCM_FILE_AVG} ${RES_OBS} > ${GRID}
        fi

        CDO remapbil,${GRID} ${REGCM_FILE_AVG} ${REGCM_FILE_REGRID}
        CDO remapbil,${GRID} ${OBS_FILE_AVG} ${OBS_FILE_REGRID}

        # Delete files
        rm ${REGCM_FILE_AVG}
        rm ${OBS_FILE_AVG}

    done
done

echo
echo "--------------- THE END POSPROCESSING ----------------"

}
