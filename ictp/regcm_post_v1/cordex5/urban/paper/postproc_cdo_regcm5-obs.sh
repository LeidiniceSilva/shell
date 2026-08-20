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

VAR_LIST="huss hfls hfss pr tasmax tasmin sfcWind"

FREQ="day"
YR="2000-2009"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="ANN DJF MAM JJA SON AC"

RES_CPC="0.25"

GRIDDES="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts_regcm"

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/urban/paper"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING ----------------"

# MAIN VARIABLE LOOP
for VAR in ${VAR_LIST[@]}; do

    # Define observational dataset
    if [ ${VAR} == "pr" ]; then
        VAR_OBS="precip"
        OBS="CPC"
    elif [ ${VAR} == "tasmax" ]; then
        VAR_OBS="tmax"
        OBS="CPC"
    elif [ ${VAR} == "tasmin" ]; then
        VAR_OBS="tmin"
        OBS="CPC"
    elif [ ${VAR} == "huss" ]; then
        VAR_OBS="huss"
        OBS="ERA5"
    elif [ ${VAR} == "hfls" ]; then
        VAR_OBS="mslhf"
        OBS="ERA5"
    elif [ ${VAR} == "hfss" ]; then
        VAR_OBS="msshf"
        OBS="ERA5"
    elif [ ${VAR} == "sfcWind" ]; then
        VAR_OBS="si10"
        OBS="ERA5"
    else
        echo "ERROR: Variable ${VAR} is not defined."
        exit 1
    fi

    echo "VARIABLE : ${VAR}"

    # INPUT FILES
    REGCM_FILE="${VAR}_${DOMAIN}_RegCM5-ERA5_${EXP}_${FREQ}_${YR}.nc"
    OBS_FILE="${VAR_OBS}_${OBS}_${YR}.nc"

    if [ ! -f ${REGCM_FILE} ]; then
        echo "ERROR: RegCM file not found:"
        echo "${REGCM_FILE}"
        exit 1
    fi
    if [ ! -f ${OBS_FILE} ]; then
        echo "ERROR: Observation file not found:"
        echo "${OBS_FILE}"
        exit 1
    fi

    # SEASON LOOP
    for SEAS in ${SEASON_LIST[@]}; do

        echo "SEASON: ${SEAS}"

        # CLIMATOLOGY
        REGCM_FILE_AVG="${VAR}_${DOMAIN}_RegCM5-ERA5_${EXP}_${SEAS}_${YR}.nc"
        OBS_FILE_AVG="${VAR_OBS}_${OBS}_${SEAS}_${YR}.nc"

        if [ ${SEAS} == "ANN" ]; then
            CDO timmean ${REGCM_FILE} ${REGCM_FILE_AVG}
            CDO timmean ${OBS_FILE} ${OBS_FILE_AVG}
        elif [ ${SEAS} == "AC" ]; then
            CDO ymonmean ${REGCM_FILE} ${REGCM_FILE_AVG}
            CDO ymonmean ${OBS_FILE} ${OBS_FILE_AVG}
        else
            [[ ${SEAS} = DJF ]] && MONS="12,01,02"
            [[ ${SEAS} = MAM ]] && MONS="03,04,05"
            [[ ${SEAS} = JJA ]] && MONS="06,07,08"
            [[ ${SEAS} = SON ]] && MONS="09,10,11"
            CDO timmean -selmonth,${MONS} ${REGCM_FILE} ${REGCM_FILE_AVG}
            CDO timmean -selmonth,${MONS} ${OBS_FILE} ${OBS_FILE_AVG}
        fi

        # COMMON 0.25 DEGREE GRID
        GRID=${DOMAIN}_CPC.grid

        if [ ! -f ${GRID} ]; then
            python3 ${GRIDDES}/griddes_ll.py ${REGCM_FILE_AVG} ${RES_CPC} > ${GRID}
        fi

        # REGRID
        REGCM_FILE_REGRID="${VAR}_${DOMAIN}_RegCM5-ERA5_${EXP}_${SEAS}_${YR}_${RES_CPC}.nc"
        OBS_FILE_REGRID="${VAR_OBS}_${DOMAIN}_${OBS}_${SEAS}_${YR}_${RES_CPC}.nc"

        CDO remapbil,${GRID} ${REGCM_FILE_AVG} ${REGCM_FILE_REGRID}
        CDO remapbil,${GRID} ${OBS_FILE_AVG} ${OBS_FILE_REGRID}

        # CPC LAND MASK
        MASK="sea_land_mask.nc"
        MASK_REGRID="sea_land_mask_${RES_CPC}.nc"

        # Regrid CPC land mask
        if [ ! -f ${MASK_REGRID} ]; then
            CDO remapbil,${GRID} ${MASK} ${MASK_REGRID}
        fi

        # APPLY LAND MASK 
	OBS_FILE_MASKED="${VAR_OBS}_${DOMAIN}_${OBS}_${SEAS}_${YR}_${RES_CPC}_land.nc"

        REGCM_FILE_MASKED="${VAR}_${DOMAIN}_RegCM5-ERA5_${EXP}_${SEAS}_${YR}_${RES_CPC}_land.nc"
        CDO ifthen ${MASK_REGRID} ${REGCM_FILE_REGRID} ${REGCM_FILE_MASKED}

        if [ ${OBS} == "ERA5" ]; then
            CDO ifthen ${MASK_REGRID} ${OBS_FILE_REGRID} ${OBS_FILE_MASKED}
        else
            cp ${OBS_FILE_REGRID} ${OBS_FILE_MASKED}
        fi

        # SELECT BOX
        REGCM_FILE_BOX="${VAR}_${DOMAIN}_RegCM5-ERA5_${EXP}_${SEAS}_${YR}_${RES_CPC}_box.nc"
        OBS_FILE_BOX="${VAR_OBS}_${DOMAIN}_${OBS}_${SEAS}_${YR}_${RES_CPC}_box.nc"

        CDO sellonlatbox,-63,-39.5,-35.25,-14.5 ${REGCM_FILE_MASKED} ${REGCM_FILE_BOX}
        CDO sellonlatbox,-63,-39.5,-35.25,-14.5 ${OBS_FILE_MASKED} ${OBS_FILE_BOX}

        # DELETE INTERMEDIATE FILES
        rm -f ${REGCM_FILE_AVG}
        rm -f ${OBS_FILE_AVG}
        rm -f ${REGCM_FILE_MASKED}

        if [ ${OBS} == "ERA5" ]; then
            rm -f ${OBS_FILE_MASKED}
        fi

    done

done

echo
echo "--------------- THE END POSPROCESSING ----------------"

}
