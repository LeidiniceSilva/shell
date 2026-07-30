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

VAR_LIST="pr tasmax tasmin"

FREQ="day"
YR="2000-2009"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

GRIDDES="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts_regcm"

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/urban/paper"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING ----------------"

for VAR in ${VAR_LIST[@]}; do

    if [ ${VAR} == "pr" ]; then
        VAR_CPC="precip"
    elif [ ${VAR} == "tasmax" ]; then
        VAR_CPC="tmax"
    elif [ ${VAR} == "tasmin" ]; then
        VAR_CPC="tmin"
    fi

    # Input files
    REGCM_FILE="${VAR}_${DOMAIN}_RegCM5-ERA5_${EXP}_${FREQ}_${YR}.nc"
    CPC_FILE="${VAR_CPC}_CPC_${FREQ}_${YR}.nc"

    if [ ! -f ${REGCM_FILE} ]; then
        echo "ERROR: RegCM file not found: ${REGCM_FILE}"
        exit 1
    fi
    if [ ! -f ${CPC_FILE} ]; then
        echo "ERROR: CPC file not found: ${CPC_FILE}"
        exit 1
    fi

    for SEAS in ${SEASON_LIST[@]}; do
        [[ ${SEAS} = DJF ]] && MONS="12,01,02" 
        [[ ${SEAS} = MAM ]] && MONS="03,04,05"
        [[ ${SEAS} = JJA ]] && MONS="06,07,08" 
        [[ ${SEAS} = SON ]] && MONS="09,10,11"

	# Postproc RegCM
    	REGCM_FILE_AVG="${VAR}_${DOMAIN}_RegCM5-ERA5_${EXP}_${SEAS}_${YR}.nc"
   	CDO timmean -selmonth,${MONS} ${REGCM_FILE} ${REGCM_FILE_AVG}

	# Postproc CPC
    	CPC_FILE_AVG="${VAR_CPC}_CPC_${SEAS}_${YR}.nc"
	CDO timmean -selmonth,${MONS} ${CPC_FILE} ${CPC_FILE_AVG}

        RES_CPC="0.25"
	REGCM_FILE_REGRID="${VAR}_${DOMAIN}_RegCM5-ERA5_${EXP}_${SEAS}_${YR}_${RES_CPC}.nc"
    	CPC_FILE_REGRID="${VAR_CPC}_${DOMAIN}_CPC_${SEAS}_${YR}_${RES_CPC}.nc"

	# Create grid
	GRID=${DOMAIN}_CPC.grid
	if [ ! -f ${GRID} ]; then
	      python3 ${GRIDDES}/griddes_ll.py ${REGCM_FILE_AVG} ${RES_CPC} > ${GRID}
	fi

	CDO remapbil,${GRID} ${REGCM_FILE_AVG} ${REGCM_FILE_REGRID}
	CDO remapbil,${GRID} ${CPC_FILE_AVG} ${CPC_FILE_REGRID}

	# Apply CPC land mask to RegCM
        CPC_MASK="${VAR_CPC}_CPC_landmask.nc"
        CPC_MASK_REGRID="${VAR_CPC}_CPC_landmask_${RES_CPC}.nc"

	if [ ! -f ${CPC_MASK} ]; then
            CDO setmisstoc,0 -gtc,0 ${CPC_FILE_AVG} ${CPC_MASK}
	fi

	REGCM_FILE_MASKED="${VAR}_${DOMAIN}_RegCM5-ERA5_${EXP}_${SEAS}_${YR}_${RES_CPC}_land.nc"
	CDO remapbil,${GRID} ${CPC_MASK} ${CPC_MASK_REGRID}
	CDO ifthen ${CPC_MASK_REGRID} ${REGCM_FILE_REGRID} ${REGCM_FILE_MASKED}

	# Select box
	REGCM_FILE_BOX="${VAR}_${DOMAIN}_RegCM5-ERA5_${EXP}_${SEAS}_${YR}_${RES_CPC}_box.nc"
	CPC_FILE_BOX="${VAR_CPC}_${DOMAIN}_CPC_${SEAS}_${YR}_${RES_CPC}_box.nc"
	CDO sellonlatbox,-63,-39.5,-35.25,-14.5 ${REGCM_FILE_MASKED} ${REGCM_FILE_BOX} 
	CDO sellonlatbox,-63,-39.5,-35.25,-14.5 ${CPC_FILE_REGRID} ${CPC_FILE_BOX} 

	# Delete files
	rm ${REGCM_FILE_AVG}
	rm ${CPC_FILE_AVG}
	rm ${CPC_FILE_REGRID}
	rm ${REGCM_FILE_REGRID}
	rm ${REGCM_FILE_MASKED}

    done
done

echo
echo "--------------- THE END POSPROCESSING ----------------"

}
