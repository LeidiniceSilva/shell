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

INST=$1 # ICTP
DOMAIN=$2 # EURR-3
DATASET=$3 # ERA5
EXP=$4 # evaluation
YR_I=$5 # 2000
YR_F=$6 # 2009

echo "INST=${INST}, DOMAIN=${DOMAIN}, DATASET=${DATASET}, EXP=${EXP}, YR_I=${YR_I}, YR_F=${YR_F}"

if [ "${DATASET}" == "ERA5" ]; then
    DATASET_="ERA5"
else
    DATASET_="ECEarth"
fi

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

# Part II
DIR_II="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/paper/dataset/RCMs/${INST}/${DOMAIN}/${EXP}/${DATASET_}/preproc"
DIR_III="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/paper/dataset/RCMs/${INST}/${DOMAIN}/${EXP}/${DATASET_}/input"

for YEAR in $(seq ${YR_I} ${YR_F}); do
    for MONTH in $(seq -w 01 12); do

        PR_FILE=$(ls "${DIR_II}"/pr_*_1hr_${YEAR}*.nc 2>/dev/null | head -n 1)
        TB_FILE=$(ls "${DIR_II}"/Tb_*_1hr_${YEAR}*.nc 2>/dev/null | head -n 1)
        [ -f "${PR_FILE}" ] || PR_FILE=$(ls "${DIR_II}"/pr_*.nc 2>/dev/null | grep "_1hr_${YEAR}" | head -n 1)
        [ -f "${TB_FILE}" ] || TB_FILE=$(ls "${DIR_II}"/Tb_*.nc 2>/dev/null | grep "_1hr_${YEAR}" | head -n 1)

        if [ ! -f "${PR_FILE}" ] || [ ! -f "${TB_FILE}" ]; then
            echo "Not found ${YEAR}-${MONTH}"
            continue
        fi

        TMP_PR="${DIR_III}/pr_${DOMAIN}_${YEAR}${MONTH}0100.nc"
        TMP_TB="${DIR_III}/Tb_${DOMAIN}_${YEAR}${MONTH}0100.nc"
        OUT_MERGE="${DIR_III}/${DOMAIN}_${DATASET}_${EXP}_1hr_${YEAR}${MONTH}0100.nc"

        CDO selyear,${YEAR} -selmon,${MONTH} "${PR_FILE}" "${TMP_PR}"
        CDO selyear,${YEAR} -selmon,${MONTH} "${TB_FILE}" "${TMP_TB}"
        CDO merge "${TMP_PR}" "${TMP_TB}" "${OUT_MERGE}"

        rm -f "${TMP_PR}" "${TMP_TB}" 
    
    done
done

}
