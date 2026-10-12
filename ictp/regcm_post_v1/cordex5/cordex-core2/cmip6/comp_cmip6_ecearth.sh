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
#__date__        = 'Oct 07, 2026'
#__description__ = 'Mask ocean and compute ETCCDI Txx index using CDO'

{
set -eo pipefail

CDO(){
    cdo -O -L -f nc4 -z zip "$@"
}

GCM="EC-Earth3-Veg"
INPUT="/home/mda_silv/scratch/CORDEX-CORE2/CMIP6/${GCM}"
OUTPUT="/home/mda_silv/scratch/CORDEX-CORE2/CMIP6/${GCM}"

# Years
START_YEAR=1970
END_YEAR=2024

# Create directories
mkdir -p "${OUTPUT}"

for YEAR in $(seq ${START_YEAR} ${END_YEAR}); do

    if [ ${YEAR} -le 2014 ]; then
        EXP="historical"
        RIPF="r5i1p1f1"
    else
        EXP="ssp370"
        RIPF="r1i1p1f1"
    fi

    IN_FILE="${INPUT}/tas/tas_3hr_${GCM}_${EXP}_${RIPF}_gr_${YEAR}01010000-${YEAR}12312100.nc"

    CDO daymax ${IN_FILE} "${INPUT}/tasmax/tasmax_day_${GCM}_${EXP}_${RIPF}_gr_${YEAR}0101-${YEAR}1231.nc"
    CDO daymin ${IN_FILE} "${INPUT}/tasmin/tasmin_day_${GCM}_${EXP}_${RIPF}_gr_${YEAR}0101-${YEAR}1231.nc"

done

echo "Done"
}
