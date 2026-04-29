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
#__description__ = 'Posprocessing the RegCM with CDO'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DOMAIN="CSAM-3" # CSAM-3 EURR-3
EXP="ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1"
DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/CPMs/${DOMAIN}"

echo
cd ${DIR_IN}
echo ${DIR_IN}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

YEARS=$(seq 2001 2009)
for YEAR in $YEARS; do
    for MON in $(seq -w 1 12); do

	echo "Processing ${YEAR} ${MON}"

        FILE_OUT_I=pr_${DOMAIN}_${EXP}_1hr_${YEAR}${MON}0100.nc
        FILE_OUT_II=Tb_${DOMAIN}_${EXP}_1hr_${YEAR}${MON}0100.nc
        FILE_OUT_III=${DOMAIN}_${EXP}_1hr_${YEAR}${MON}0100.nc

        CDO seldate,${YEAR}-${MON}-01,${YEAR}-${MON}-31 pr_${DOMAIN}_${EXP}_1hr_2000-2009.nc $FILE_OUT_I
        CDO seldate,${YEAR}-${MON}-01,${YEAR}-${MON}-31 Tb_${DOMAIN}_${EXP}_1hr_2000-2009.nc $FILE_OUT_II
        CDO merge $FILE_OUT_I $FILE_OUT_II ${DIR_IN}/input/$FILE_OUT_III

	echo "Processed $DIR_OUT_III"

    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
