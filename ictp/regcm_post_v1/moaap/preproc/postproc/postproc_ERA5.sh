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
#__date__        = 'Jan 20, 2026'
#__description__ = 'Posprocessing the OBS with CDO'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="ERA5"
EXP_OUT="ERA5_reanalysis"

DIR_BASE="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/ERA5"

echo
cd ${DIR_BASE}
echo ${DIR_BASE}

echo
echo "--------------- INIT POSPROCESSING ----------------"

# Preprocess base files 
CDO merge avg_tnlwrf_${EXP}_*.nc avg_tnlwrf_${EXP}_1hr_2000-2009.nc
CDO mulc,-1 avg_tnlwrf_${EXP}_1hr_2000-2009.nc avg_tnlwrf_${EXP}_reanalysis_1hr_2000-2009.nc

CDO mulc,1000 tp_${EXP}_1hr_2000-2009.nc tp_${EXP}_reanalysis_1hr_2000-2009.nc

# Domain specifications
DOMAINS=(
    "CAR-4:-119.0219,-58.01409,9.064618,35.89941"
    "CSAM-3:-78.81965,-35.32753,-36.70233,-12.24439"
    "EURR-3:-25.28493,38.42932,33.25481,64.97"
)

YEARS=$(seq 2000 2009)

# Crop into domains and split into monthly files
for DOMAIN_INFO in "${DOMAINS[@]}"; do

    DOMAIN=$(echo "$DOMAIN_INFO" | cut -d':' -f1)
    BOX=$(echo "$DOMAIN_INFO" | cut -d':' -f2)

    DIR_I="${DIR_BASE}/${DOMAIN}"
    DIR_II="${DIR_BASE}/${DOMAIN}/input"

    mkdir -p "${DIR_I}" "${DIR_II}"

    # Crop variables to region
    CDO sellonlatbox,${BOX} avg_tnlwrf_${EXP}_reanalysis_1hr_2000-2009.nc ${DIR_I}/Tb_${DOMAIN}_${EXP_OUT}_1hr_2000-2009.nc
    CDO sellonlatbox,${BOX} tp_${EXP}_reanalysis_1hr_2000-2009.nc ${DIR_I}/tp_${DOMAIN}_${EXP_OUT}_1hr_2000-2009.nc

    cd ${DIR_II}
    echo ${DIR_II}

    FILE_IN_I=${DIR_I}/tp_${DOMAIN}_${EXP_OUT}_1hr_2000-2009.nc 
    FILE_IN_II=${DIR_I}/Tb_${DOMAIN}_${EXP_OUT}_1hr_2000-2009.nc

    for YEAR in $YEARS; do
        for MON in $(seq -w 1 12); do

            echo "Processing ${YEAR} ${MON} for ${DOMAIN}"

            FILE_OUT_I=tp_${DOMAIN}_${EXP_OUT}_1hr_${YEAR}${MON}0100.nc
            FILE_OUT_II=Tb_${DOMAIN}_${EXP_OUT}_1hr_${YEAR}${MON}0100.nc
            FILE_OUT_III=${DOMAIN}_${EXP_OUT}_1hr_${YEAR}${MON}0100.nc

            CDO seldate,${YEAR}-${MON}-01,${YEAR}-${MON}-31 $FILE_IN_I $FILE_OUT_I
            CDO seldate,${YEAR}-${MON}-01,${YEAR}-${MON}-31 $FILE_IN_II $FILE_OUT_II
            CDO merge $FILE_OUT_I $FILE_OUT_II $FILE_OUT_III

            echo "Processed $FILE_OUT_III"

        done
    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
