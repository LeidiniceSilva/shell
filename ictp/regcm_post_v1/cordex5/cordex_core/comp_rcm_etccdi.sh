#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J ETCCDI
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Compute ETCCDI indies using CDO-ECA'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DOMAIN="CAM"
GCM="MPI"

# Input files
INPUT="/leonardo_work/ICT26_ESP/CORDEX-CMIP6_OLCF/${DOMAIN}-${GCM}"
OUTPUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/cordex_core/RegCM/${DOMAIN}-${GCM}/${DOMAIN}-12"
TMP="${OUTPUT}/tmp"

# Variaveis regcm
VAR_LIST="pr tasmin"

# Create temporary directory
mkdir -p ${TMP}
mkdir -p ${OUTPUT}

# Loop para processar ano a ano
for YEAR in {2020..2024}; do

  echo "Processing year ${year}"

  # Merge monthly files into one annual file
  for VAR in ${VAR_LIST}; do

    echo "Merging ${VAR} files for ${YEAR}"

    FILES=$(ls ${INPUT}/${DOMAIN}-12_${GCM}_${VAR}_daily.${YEAR}*.nc 2>/dev/null)

    if [ -z "${FILES}" ]; then
      echo "WARNING: No files found for ${VAR} in ${YEAR}"
      continue
    fi

    CDO mergetime ${FILES} ${TMP}/RegCM_${GCM}_${VAR}_${YEAR}.nc

  done

  # RX1day (max 1-day prec)
  CDO mulc,86400 \
    ${TMP}/RegCM_${GCM}_pr_${YEAR}.nc \
    ${TMP}/RegCM_${GCM}_pr_mmday_${YEAR}.nc

  CDO eca_rx1day \
    ${TMP}/RegCM_${GCM}_pr_mmday_${YEAR}.nc \
    ${OUTPUT}/RegCM_${GCM}_rx1day_${YEAR}.nc

  # TN20 (mn2t > 20°C)
  CDO eca_tr,20 \
    ${TMP}/RegCM_${GCM}_tasmin_${YEAR}.nc \
    ${OUTPUT}/RegCM_${GCM}_tn20_${YEAR}.nc

  # Delete
  rm -f ${TMP}/RegCM_${GCM}_pr_${YEAR}.nc
  rm -f ${TMP}/RegCM_${GCM}_tasmin_${YEAR}.nc
  rm -f ${TMP}/RegCM_${GCM}_pr_mmday_${YEAR}.nc

done

# Merge years

CDO mergetime \
  ${OUTPUT}/RegCM_${GCM}_rx1day_[0-9][0-9][0-9][0-9].nc \
  ${OUTPUT}/RX1day_RegCM_${GCM}_1970-2024.nc

CDO mergetime \
  ${OUTPUT}/RegCM_${GCM}_tn20_[0-9][0-9][0-9][0-9].nc \
  ${OUTPUT}/TN20_RegCM_${GCM}_1970-2024.nc

}
