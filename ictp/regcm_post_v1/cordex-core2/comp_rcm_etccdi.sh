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
#__description__ = 'Compute ETCCDI indices using CDO-ECA'

{
set -eo pipefail

CDO(){
    cdo -O -L -f nc4 -z zip "$@"
}

DOMAIN="CAM"
GCM="MPI"

# Input files
INPUT="/leonardo_work/ICT26_ESP/CORDEX-CMIP6_OLCF/${DOMAIN}-${GCM}"

# Output
OUTPUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX-CORE2/RegCM/${DOMAIN}-12/${DOMAIN}-${GCM}"
TMP="${OUTPUT}/tmp"

# Variables
VAR_LIST="pr tasmin"

# Years
START_YEAR=1970
END_YEAR=2024

# Create directories
mkdir -p "${TMP}"
mkdir -p "${OUTPUT}"
mkdir -p "${OUTPUT}/RX1day"
mkdir -p "${OUTPUT}/TN20"

# Merge daily files
for VAR in ${VAR_LIST}; do
    for YEAR in $(seq ${START_YEAR} ${END_YEAR}); do
        FILES=$(ls ${INPUT}/${DOMAIN}-12_${GCM}_${VAR}_daily.${YEAR}*.nc 2>/dev/null || true)

        if [ -z "${FILES}" ]; then
            echo "WARNING: No files found for ${VAR} in ${YEAR}"
            continue
        fi

        CDO mergetime ${FILES} ${TMP}/RegCM_${GCM}_${VAR}_day_${YEAR}.nc

    done

    # Merge annual files
    CDO mergetime ${TMP}/RegCM_${GCM}_${VAR}_day_[0-9][0-9][0-9][0-9].nc ${TMP}/RegCM_${GCM}_${VAR}_day_${START_YEAR}-${END_YEAR}.nc

    # Select years again
    for YEAR in $(seq ${START_YEAR} ${END_YEAR}); do
        CDO selyear,${YEAR} ${TMP}/RegCM_${GCM}_${VAR}_day_${START_YEAR}-${END_YEAR}.nc ${TMP}/RegCM_${GCM}_${VAR}_${YEAR}_selyear.nc
    done

done

# Convert kg m-2 s-1 to mm/day
for YEAR in $(seq ${START_YEAR} ${END_YEAR}); do
    CDO mulc,86400 ${TMP}/RegCM_${GCM}_pr_${YEAR}_selyear.nc ${TMP}/RegCM_${GCM}_pr_mmday_${YEAR}.nc
done

# Calculate RX1DAY
for YEAR in $(seq ${START_YEAR} ${END_YEAR}); do
    echo "RX1day ${YEAR}"
    CDO eca_rx1day ${TMP}/RegCM_${GCM}_pr_mmday_${YEAR}.nc ${OUTPUT}/RegCM_${GCM}_rx1day_${YEAR}.nc
done

# Calculate TN20
for YEAR in $(seq ${START_YEAR} ${END_YEAR}); do
    echo "TN20 ${YEAR}"
    CDO eca_tr,20 ${TMP}/RegCM_${GCM}_tasmin_${YEAR}_selyear.nc ${OUTPUT}/RegCM_${GCM}_tn20_${YEAR}.nc
done

# Merge RX1DAY 
CDO mergetime ${OUTPUT}/RegCM_${GCM}_rx1day_[0-9][0-9][0-9][0-9].nc ${OUTPUT}/RX1day/RX1day_RegCM_${GCM}_${START_YEAR}-${END_YEAR}.nc

# Merge TN20 
CDO mergetime ${OUTPUT}/RegCM_${GCM}_tn20_[0-9][0-9][0-9][0-9].nc ${OUTPUT}/TN20/TN20_RegCM_${GCM}_${START_YEAR}-${END_YEAR}.nc

echo "Done"

}
