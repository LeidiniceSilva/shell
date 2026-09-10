#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 8
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__     = 'Leidinice Silva'
#__email__      = 'leidinicesilva@gmail.com'
#__date__       = 'Jan 20, 2026'
#__description__ = 'Posprocessing the OBS with CDO'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip "$@"
}

EXP="GPM"
DOMAIN_LIST=("CSAM-3") # CAR-4 CSAM-3 EURR-3

DIR_I="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/paper/dataset/GPM/globe/GPM"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
echo "--------------- INIT POSPROCESSING ----------------"

for DOMAIN in "${DOMAIN_LIST[@]}"; do

    DIR_II="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/paper/dataset/GPM/${DOMAIN}/preproc"

    echo
    cd ${DIR_II}
    echo ${DIR_II}

    for YEAR in $(seq 2000 2009); do
        for MON in $(seq -w 06 06); do
	    echo "Processing ${DOMAIN} ${YEAR} ${MON}"

            IN_FILE="${DIR_I}/MERGIR/mergir_${YEAR}${MON}_4km-pixel_1hr.nc"
            OUT_FILE="Tb_${EXP}_MERGIR_${DOMAIN}_1hr_${YEAR}${MON}.nc"

            if [ ${DOMAIN} == "CAR-4" ]; then
		${BIN}/regrid "${IN_FILE}" 9.064618,35.89941,0.25 -119.0219,-58.01409,0.25 bil
            elif [ ${DOMAIN} == "CSAM-3" ]; then
		${BIN}/regrid "${IN_FILE}" -36.70233,-12.24439,0.25 -78.81965,-35.32753,0.25 bil
            else
		${BIN}/regrid "${IN_FILE}" 36,58,0.25 -22,36,0.25 bil
            fi

            mv "mergir_${YEAR}${MON}_4km-pixel_1hr_lonlat.nc" "${OUT_FILE}"

        done
    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}



