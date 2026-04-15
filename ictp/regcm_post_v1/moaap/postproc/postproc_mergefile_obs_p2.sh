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

EXP="ERA5_reanalysis"

echo
echo "--------------- INIT POSPROCESSING ----------------"

DOMAINS=("CSAM-3")   
YEARS=$(seq 2000 2009)

for DOMAIN in "${DOMAINS[@]}"; do

    DIR_I="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/ERA5/${DOMAIN}"
    DIR_II="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/ERA5/${DOMAIN}/input"

    echo
    cd ${DIR_II}
    echo ${DIR_II}

    FILE_IN_I=${DIR_I}/tp_${DOMAIN}_${EXP}_1hr_2000-2009.nc 
    FILE_IN_II=${DIR_I}/Tb_${DOMAIN}_${EXP}_1hr_2000-2009.nc

    for YEAR in $YEARS; do
        for MON in $(seq -w 1 12); do

	    echo "Processing ${YEAR} ${MON}"

            FILE_OUT_I=tp_${DOMAIN}_${EXP}_1hr_${YEAR}${MON}0100.nc
            FILE_OUT_II=Tb_${DOMAIN}_${EXP}_1hr_${YEAR}${MON}0100.nc
            FILE_OUT_III=${DOMAIN}_${EXP}_1hr_${YEAR}${MON}0100.nc

            CDO seldate,${YEAR}-${MON}-01,${YEAR}-${MON}-31 $FILE_IN_I $FILE_OUT_I
            CDO seldate,${YEAR}-${MON}-01,${YEAR}-${MON}-31 $FILE_IN_II $FILE_OUT_II
            CDO merge $FILE_OUT_I $FILE_OUT_II $FILE_OUT_III

	    echo "Processed $DIR_OUT_III"

        done
    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}

