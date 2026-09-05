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
#__description__ = 'Postprocessing the RegCM5 output with CDO'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip "$@"
}

EXP_LIST="NoTo-EUR WSM5-EUR WSM7-EUR" # NoTo-EUR WSM5-EUR WSM7-EUR WDM7-EUR
VAR_LIST="cli clw" # cli clw

YR="2000-2009"
SEASON_LIST="DJF MAM JJA SON ANN"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/postproc/paper"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/postproc/paper/vert"

mkdir -p ${DIR_OUT}
cd ${DIR_OUT}

echo "--------------- INIT POSTPROCESSING MODEL ----------------"

ERA5_MASK="${DIR_IN}/sea_land_mask.nc"

# --- PROCESS EXPERIMENTS ---
for EXP in ${EXP_LIST}; do
    echo "EXPERIMENT : ${EXP}"

    for VAR in ${VAR_LIST}; do
        echo "VARIABLE : ${VAR}"

        if [ ${VAR} == "cl" ]; then
            VAR_OBS="cc"
            OBS="ERA5"
        elif [ ${VAR} == "cli" ]; then
	    VAR_OBS="ciwc"
            OBS="ERA5"
	elif [ ${VAR} == "clw" ]; then
            VAR_OBS="clwc"
            OBS="ERA5"
	else
            echo "ERROR: Variable ${VAR} is not defined."
            exit 1
	fi

        for SEAS in ${SEASON_LIST}; do
            echo "SEASON : ${SEAS}"

	    # INPUT FILES
	    REGCM_FILE="${DIR_IN}/${VAR}_RegCM5_${EXP}_day_${YR}.nc"
	    OBS_FILE="${DIR_IN}/${VAR_OBS}_${OBS}_mon_${YR}.nc"
        
            REGCM_AVG="${VAR}_RegCM5_${EXP}_${SEAS}_${YR}.nc"
            OBS_AVG="${VAR_OBS}_${OBS}_${SEAS}_${YR}.nc"

            if [ ${SEAS} == "ANN" ]; then
		CDO timmean ${REGCM_FILE} ${REGCM_AVG}
		CDO timmean ${OBS_FILE} ${OBS_AVG}
            else
		[[ ${SEAS} = DJF ]] && MONS="12,01,02"
		[[ ${SEAS} = MAM ]] && MONS="03,04,05"
		[[ ${SEAS} = JJA ]] && MONS="06,07,08"
		[[ ${SEAS} = SON ]] && MONS="09,10,11"
		CDO timmean -selmonth,${MONS} ${REGCM_FILE} ${REGCM_AVG}
		CDO timmean -selmonth,${MONS} ${OBS_FILE} ${OBS_AVG}
	    fi

            REGCM_BOX="${VAR}_RegCM5_${EXP}_${SEAS}_${YR}_land_box.nc"
            OBS_BOX="${VAR_OBS}_${OBS}_${SEAS}_${YR}_land_box.nc"

	    CDO ifthen -sellonlatbox,1,17,40,50 -remapnn,${REGCM_AVG} ${ERA5_MASK} -sellonlatbox,1,17,40,50 ${REGCM_AVG} ${REGCM_BOX}
	    CDO ifthen -sellonlatbox,1,17,40,50 ${ERA5_MASK} -sellonlatbox,1,17,40,50 ${OBS_AVG} ${OBS_BOX}

	done
    done
done

echo "--------------- THE END POSTPROCESSING MODEL ----------------"

}

