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
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the RegCM5 output with CDO'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DOMAIN="EURR-3"
EXP="ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1"
DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/${DOMAIN}/input"

echo
cd ${DIR_IN}
echo ${DIR_IN}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

FILE_IN_I=pr_${DOMAIN}_${EXP}_1hr_2000-2009.nc
FILE_IN_II=Tb_${DOMAIN}_${EXP}_1hr_2000-2009.nc

YEARS=$(seq 2000 2009)
for YEAR in $YEARS; do
    for MON in $(seq -w 1 12); do

	echo "Processing ${YEAR} ${MON}"

        FILE_OUT_I=pr_${DOMAIN}_${EXP}_1hr_${YEAR}${MON}0100.nc
        FILE_OUT_II=Tb_${DOMAIN}_${EXP}_1hr_${YEAR}${MON}0100.nc
        FILE_OUT_III=${DOMAIN}_${EXP}_1hr_${YEAR}${MON}0100.nc

        cdo seldate,${YEAR}-${MON}-01,${YEAR}-${MON}-31 $FILE_IN_I $FILE_OUT_I
        cdo seldate,${YEAR}-${MON}-01,${YEAR}-${MON}-31 $FILE_IN_II $FILE_OUT_II
        cdo merge $FILE_OUT_I $FILE_OUT_II $FILE_OUT_III

	echo "Processed $DIR_OUT_III"

    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
