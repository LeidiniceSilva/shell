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

EXP="GPM"
DOMAINS=(
    "CAR-4:-119.0219,-58.01409,9.064618,35.89941"
    "CSAM-3:-78.81965,-35.32753,-36.70233,-12.24439"
    "EURR-3:36,58,-22,36"
)

DIR_I="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/GPM/globe/MERGE"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
echo "--------------- INIT POSPROCESSING ----------------"

for DOMAIN_INFO in "${DOMAINS[@]}"; do

    DOMAIN=$(echo "$DOMAIN_INFO" | cut -d':' -f1)
    GRID=$(echo "$DOMAIN_INFO" | cut -d':' -f2)

    DIR_II="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/GPM/${DOMAIN}/preproc"
    mkdir -p ${DIR_II}

    echo
    cd ${DIR_II}
    echo ${DIR_II}

    for YEAR in $(seq 2000 2009); do

        if [ ${YEAR} -eq 2000 ]; then
            START_MON=6
        else
            START_MON=1
        fi

        for MON in $(seq -w ${START_MON} 12); do

            echo "Processing ${DOMAIN} ${YEAR} ${MON}"
            ${BIN}/./regrid ${DIR_I}/IMERG/imerg_${YEAR}${MON}_1hr_v07b.nc ${GRID},0.25 bil
            CDO chnname,PR,pr imerg_${YEAR}${MON}_1hr_v07b_regrid.nc pr_${EXP}_${DOMAIN}_1hr_${YEAR}${MON}.nc

        done
    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
