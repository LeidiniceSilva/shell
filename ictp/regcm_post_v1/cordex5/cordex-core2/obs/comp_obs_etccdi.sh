#!/bin/bash

#SBATCH -N 1
#SBATCH -t CORDEX-CORE2
#SBATCH -J FPS-SESA
#SBATCH -p esp
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

#Dataset
DATASET="CPC" 

# Input files
INPUT="/home/netapp-clima-scratch/mda_silv/CORDEX-CORE2/OBS/${DATASET}"

# Output
OUTPUT="/home/netapp-clima-scratch/mda_silv/CORDEX-CORE2/OBS/${DATASET}"
TMP="${OUTPUT}/tmp"

# Variables
VAR_LIST="tmin tmax " # precip tmax tmin

# Years
START_YEAR=1979
END_YEAR=2024

# Create directories
mkdir -p "${TMP}"
mkdir -p "${OUTPUT}"
mkdir -p "${OUTPUT}/RR1"
mkdir -p "${OUTPUT}/TXx"
mkdir -p "${OUTPUT}/TN20"

# Merge daily files
for VAR in ${VAR_LIST}; do

    FILE=${INPUT}/${VAR}.cpc.day.1979-2024.nc

    for YEAR in $(seq ${START_YEAR} ${END_YEAR}); do

 	if [ ${VAR} == 'precip' ]
        then
        CDO selyear,${YEAR} ${FILE} ${TMP}/${VAR}_day_${DATASET}_mmday_${YEAR}_lm.nc
	CDO eca_rr1 ${TMP}/${VAR}_day_${DATASET}_mmday_${YEAR}_lm.nc ${TMP}/RR1_${DATASET}_${YEAR}.nc
	CDO eca_rx1day ${TMP}/${VAR}_day_${DATASET}_mmday_${YEAR}_lm.nc ${TMP}/RX1day_${DATASET}_${YEAR}.nc
 	elif [ ${VAR} == 'tmax' ]
        then
        CDO selyear,${YEAR} ${FILE} ${TMP}/${VAR}_day_${DATASET}_Kelvin_${YEAR}_lm.nc
	CDO -subc,273.15 -yearmax ${TMP}/${VAR}_day_${DATASET}_Kelvin_${YEAR}_lm.nc ${TMP}/TXx_${DATASET}_${YEAR}.nc
	else
        CDO selyear,${YEAR} ${FILE} ${TMP}/${VAR}_day_${DATASET}_Kelvin_${YEAR}_lm.nc
	CDO eca_tr,20 ${TMP}/${VAR}_day_${DATASET}_Kelvin_${YEAR}_lm.nc ${TMP}/TN20_${DATASET}_${YEAR}.nc
	fi
	
    done
done

#CDO mergetime ${TMP}/RR1_${DATASET}_*.nc ${OUTPUT}/RR1/RR1_${DATASET}_${START_YEAR}-${END_YEAR}.nc
#CDO mergetime ${TMP}/RX1day_${DATASET}_*.nc ${OUTPUT}/RX1day/RX1day_${DATASET}_${START_YEAR}-${END_YEAR}.nc
CDO mergetime ${TMP}/TXx_${DATASET}_*.nc ${OUTPUT}/TXx/TXx_${DATASET}_${START_YEAR}-${END_YEAR}.nc
CDO mergetime ${TMP}/TN20_${DATASET}_*.nc ${OUTPUT}/TN20/TN20_${DATASET}_${START_YEAR}-${END_YEAR}.nc

echo "Done"

}
