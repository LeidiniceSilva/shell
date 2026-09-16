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

DOMAIN=$1  
YR_I=2015
YR_F=2042
#EXP="ERA5_evaluation"
#EXP="EC-Earth3-Veg_historical"
EXP="EC-Earth3-Veg_ssp370"

BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

if [ ${DOMAIN} = 'SAM-12'  ]; then
	DIR_I="/leonardo_work/ICT26_ESP/CORDEX-CMIP6/DD/SAM-12/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr/v20260622"
elif [ ${DOMAIN} = 'EUR-12'  ]; then
	#DIR_I="/leonardo_work/ICT26_ESP/CORDEX-CMIP6/DD/EUR-12/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr/v20250415"
	#DIR_I="/leonardo_work/ICT26_ESP/CORDEX-CMIP6/DD/EUR-12/ICTP/EC-Earth3-Veg/historical/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr/v20250415"
	DIR_I="/leonardo_work/ICT26_ESP/CORDEX-CMIP6/DD/EUR-12/ICTP/EC-Earth3-Veg/ssp370/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr/v20250415"
else
	echo "Error: Unknown DOMAIN = ${DOMAIN}"
	exit 1
fi	

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

# Part I
#DIR_II="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/paper/dataset/RCMs/ICTP/EUR-12/evaluation/ERA5/preproc"
#DIR_II="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/paper/dataset/RCMs/ICTP/EUR-12/historical/ECEarth/preproc"
DIR_II="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/paper/dataset/RCMs/ICTP/EUR-12/ssp370/ECEarth/preproc"

# Loop year by year 
for FILE in "${DIR_I}"/pr_*.nc; do
    [ -f "${FILE}" ] || continue

    BASENAME=$(basename "${FILE}")
    YEAR=$(echo "${BASENAME}" | sed -E 's/.*_1hr_([0-9]{4})[0-9]{8}-.*/\1/')
    if [ "${YEAR}" -ge ${YR_I} ] && [ "${YEAR}" -le ${YR_F} ]; then
        CDO mulc,3600 "${FILE}" "${DIR_II}/${BASENAME}"
    fi

done

# Part II
#DIR_III="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/paper/dataset/RCMs/ICTP/EUR-12/evaluation/ERA5/input"
#DIR_III="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/paper/dataset/RCMs/ICTP/EUR-12/historical/ECEarth/input"
DIR_III="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/paper/dataset/RCMs/ICTP/EUR-12/ssp370/ECEarth/input"

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
        OUT_MERGE="${DIR_III}/${DOMAIN}_${EXP}_1hr_${YEAR}${MONTH}0100.nc"

        CDO selyear,${YEAR} -selmon,${MONTH} "${PR_FILE}" "${TMP_PR}"
        CDO selyear,${YEAR} -selmon,${MONTH} "${TB_FILE}" "${TMP_TB}"
        CDO merge "${TMP_PR}" "${TMP_TB}" "${OUT_MERGE}"

        if [ ${DOMAIN} == "SAM-12" ]; then
	    ${BIN}/regrid "${OUT_MERGE}" -36.70233,-12.24439,0.25 -78.81965,-35.32753,0.25 bil
        else
	    ${BIN}/regrid "${OUT_MERGE}" 36,58,0.25 -22,36,0.25 bil
        fi

        rm -f "${TMP_PR}" "${TMP_TB}" 
    
    done
done

}
