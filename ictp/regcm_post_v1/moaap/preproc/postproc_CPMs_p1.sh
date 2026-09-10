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

DOMAIN=$1  # CAR-4 CSAM-3 EURR-3
EXP="ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

if [ ${DOMAIN} = 'CAR-4'  ]; then
	DIR_I="/leonardo_work/ICT26_ESP/jdeleeuw/CAR-4/ERA5/high_soil_moisture_OCN/ERA5/CAR-4/postproc/CORDEX-CMIP6/DD/CAR-4/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr"
elif [ ${DOMAIN} = 'CSAM-3'  ]; then
	DIR_I="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/ERA5/ERA5-CSAM-3/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr"
elif [ ${DOMAIN} = 'EURR-3'  ]; then
	DIR_I="/leonardo_work/ICT26_ESP/CORDEX-CMIP6/DD/EURR-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr/v20251218"
else
	echo "Error: Unknown DOMAIN = ${DOMAIN}"
	exit 1
fi	

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

# Part I
DIR_II="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/paper/dataset/CPMs/ICTP/${DOMAIN}/historical/ERA5/preproc"

# Loop year by year 
for FILE in "${DIR_I}"/pr_*.nc; do
    [ -f "${FILE}" ] || continue

    BASENAME=$(basename "${FILE}")
    YEAR=$(echo "${BASENAME}" | sed -E 's/.*_1hr_([0-9]{4})[0-9]{8}-.*/\1/')

    if [ "${YEAR}" -ge 2000 ] && [ "${YEAR}" -le 2009 ]; then
        CDO mulc,3600 "${FILE}" "${DIR_II}/${BASENAME}"
    fi
done

# Part II
DIR_III="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/paper/dataset/CPMs/ICTP/${DOMAIN}/historical/ERA5/input"

for YEAR in {2000..2009}; do
    for MONTH in $(seq -w 1 12); do

        PR_FILE=$(ls "${DIR_II}"/pr_*_1hr_${YEAR}*.nc 2>/dev/null | head -n 1)
        TB_FILE=$(ls "${DIR_II}"/Tb_*_1hr_${YEAR}*.nc 2>/dev/null | head -n 1)
        [ -f "${PR_FILE}" ] || PR_FILE=$(ls "${DIR_II}"/pr_*.nc 2>/dev/null | grep "_1hr_${YEAR}" | head -n 1)
        [ -f "${TB_FILE}" ] || TB_FILE=$(ls "${DIR_II}"/Tb_*.nc 2>/dev/null | grep "_1hr_${YEAR}" | head -n 1)

        if [ ! -f "${PR_FILE}" ] || [ ! -f "${TB_FILE}" ]; then
            echo "Not found ${YEAR}-${MONTH}"
            continue
        fi

        TMP_PR="${DIR_III}/pr_${DOMAIN}_${YEAR}${MONTH}_tmp.nc"
        TMP_TB="${DIR_III}/Tb_${DOMAIN}_${YEAR}${MONTH}_tmp.nc"
        OUT_MERGE="${DIR_III}/${DOMAIN}_ERA5_evaluation_1hr_${YEAR}${MONTH}.nc"

        CDO selyear,${YEAR} -selmon,${10#$MONTH} "${PR_FILE}" "${TMP_PR}"
        CDO selyear,${YEAR} -selmon,${10#$MONTH} "${TB_FILE}" "${TMP_TB}"
        CDO merge "${TMP_PR}" "${TMP_TB}" "${OUT_MERGE}"

        if [ ${DOMAIN} == "CAR-4" ]; then
	    ${BIN}/regrid "${OUT_MERGE}" 9.064618,35.89941,0.25 -119.0219,-58.01409,0.25 bil
        elif [ ${DOMAIN} == "CSAM-3" ]; then
	    ${BIN}/regrid "${OUT_MERGE}" -36.70233,-12.24439,0.25 -78.81965,-35.32753,0.25 bil
        else
	    ${BIN}/regrid "${OUT_MERGE}" -22,36,0.25 36,58,0.25 bil
        fi

        # rm -f "${TMP_PR}" "${TMP_TB}" "${OUT_MERGE}"
    
    done
done

}
