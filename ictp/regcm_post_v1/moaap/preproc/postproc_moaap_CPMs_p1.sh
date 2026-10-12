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

DOMAIN=$1 # CSAM-3
DATASET=$2 # ERA5
EXP=$3 # evaluation
YR_I=$4 # 2000
YR_F=$5 # 2009

if [ ${DATASET} == "ERA5" ]; then
    ${DATASET_} = "ERA5"
else
    ${DATASET_} = "ECEarth"
fi

if [ ${DOMAIN} = 'CSAM-3'  ]; then
	DIR_I="/leonardo_work/ICT26_ESP/CORDEX-CMIP6/DD/${DOMAIN}/ICTP/${DATASET}/${EXP}/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr/v20260622"
elif [ ${DOMAIN} = 'EURR-3'  ]; then
	DIR_I="/leonardo_work/ICT26_ESP/CORDEX-CMIP6/DD/${DOMAIN}/ICTP/${DATASET}/${EXP}/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr/v20251218"
else
	echo "Error: Unknown DOMAIN = ${DOMAIN}"
	exit 1
fi	

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

# Part I
DIR_II="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/paper/dataset/CPMs/ICTP/${DOMAIN}/${EXP}/${DATASET_}/preproc"

# Loop year by year 
for FILE in "${DIR_I}"/pr_*.nc; do
    [ -f "${FILE}" ] || continue

    BASENAME=$(basename "${FILE}")
    YEAR=$(echo "${BASENAME}" | sed -E 's/.*_1hr_([0-9]{4})[0-9]{8}-.*/\1/')
    if [ "${YEAR}" -ge ${YR_I} ] && [ "${YEAR}" -le ${YR_F} ]; then
        CDO mulc,3600 "${FILE}" "${DIR_II}/${BASENAME}"
    fi

done

}
