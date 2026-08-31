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

YR="2000-2009"
VAR="pr"
EXP_LIST="NoTo-EUR WSM5-EUR WSM7-EUR WDM7-EUR"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/postproc/paper"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/postproc/paper/pdf"

mkdir -p ${DIR_OUT}
cd ${DIR_OUT}

echo "--------------- INIT POSTPROCESSING MODEL ----------------"

ERA5_MASK="${DIR_IN}/sea_land_mask.nc"
if [ ! -f "${ERA5_MASK}" ]; then
    echo "ERROR: ERA5 mask file not found: ${ERA5_MASK}"
    exit 1
fi

# PROCESS EXPERIMENTS 
for EXP in ${EXP_LIST}; do
    echo "EXPERIMENT : ${EXP}"

    for FREQ in 1hr; do
        echo "FREQUENCY : ${FREQ}"

        REGCM_FILE="${DIR_IN}/${VAR}_RegCM5_${EXP}_${FREQ}_${YR}.nc"
        REGCM_BOX="${VAR}_RegCM5_${EXP}_${FREQ}_${YR}_box.nc"
        REGCM_LAND="${VAR}_RegCM5_${EXP}_${FREQ}_${YR}_land_box.nc"

        if [ -f "${REGCM_FILE}" ]; then
            CDO remapnn,${REGCM_FILE} ${ERA5_MASK} era5_mask_remap.nc
            CDO sellonlatbox,1,17,40,50 ${REGCM_FILE} ${REGCM_BOX}
            CDO sellonlatbox,1,17,40,50 era5_mask_remap.nc era5_mask_box.nc
            CDO ifthen era5_mask_box.nc ${REGCM_BOX} ${REGCM_LAND}
            rm -f era5_mask_remap.nc era5_mask_box.nc
        else
            echo "ERROR: RegCM file not found: ${REGCM_FILE}"
            exit 1
        fi
    done
done

exit

# PROCESS CPC 
echo "PROCESSING OBSERVATION: CPC (DAILY)"
CPC_FILE="${DIR_IN}/precip_CPC_day_${YR}.nc"
CPC_BOX="precip_CPC_day_${YR}_land_box.nc"

if [ -f "${CPC_FILE}" ]; then
    CDO sellonlatbox,1,17,40,50 ${CPC_FILE} ${CPC_BOX}
else
    echo "ERROR: CPC file not found: ${CPC_FILE}"
    exit 1
fi

# PROCESS ERA5 
echo "PROCESSING OBSERVATION: ERA5 (DAILY & HOURLY)"
for FREQ in day 1hr; do
    ERA5_FILE="${DIR_IN}/tp_ERA5_${FREQ}_${YR}.nc"
    ERA5_BOX="tp_ERA5_${FREQ}_${YR}_land_box.nc"

    if [ -f "${ERA5_FILE}" ]; then
        CDO ifthen ${ERA5_MASK_BOX} -sellonlatbox,1,17,40,50 ${ERA5_FILE} ${ERA5_BOX}
    else
        echo "ERROR: ERA5 file not found: ${ERA5_FILE}"
        exit 1
    fi
done

echo "--------------- THE END POSTPROCESSING MODEL ----------------"
}
