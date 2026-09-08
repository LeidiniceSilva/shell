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
REGRID="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/CPMs/historical/"

if [ ${DOMAIN} = 'CAR-4'  ]; then
	DIR_I="/leonardo_work/ICT26_ESP/jdeleeuw/CAR-4/ERA5/high_soil_moisture_OCN/ERA5/CAR-4/postproc/CORDEX-CMIP6/DD/CAR-4/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr"
elif [ ${DOMAIN} = 'CSAM-3'  ]; then
	DIR_I="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/ERA5/ERA5-CSAM-3/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr"
elif [ ${DOMAIN} = 'EURR-3'  ]; then
	DIR_I="/leonardo_work/ICT26_ESP/jdeleeuw/EURR-3/ERA5/high_soil_moisture/ERA5/EURR-3/postproc/CORDEX-CMIP6/DD/EURR-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr"
else
	echo "Error: Unknown DOMAIN = ${DOMAIN}"
	exit 1
fi	

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

# Part I
DIR_II="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/CPMs/historical/${DOMAIN}/preproc"
mkdir -p "${DIR_II}/pr" "${DIR_II}/Tb"

for FILE in ${DIR_I}/pr_*.nc; do
    [ -f "${FILE}" ] || continue

    BASENAME=$(basename "${FILE}")
    YEAR=$(echo "${BASENAME}" | sed -E 's/.*_1hr_([0-9]{4}).*/\1/')

    if [ "${YEAR}" -ge 2000 ] && [ "${YEAR}" -le 2009 ]; then
        echo "Processing ${BASENAME}"
        CDO mulc,3600 "${FILE}" "${DIR_II}/pr/${BASENAME}"
    fi
done

# Part II
DIR_III="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/CPMs/historical/${DOMAIN}/input"
mkdir -p "${DIR_III}"

for YEAR in {2000..2009}; do
    for MONTH in {01..12}; do

        PR_FILES="${DIR_II}/pr/pr_*_1hr_${YEAR}${MONTH}*.nc"
        TB_FILES="${DIR_II}/Tb/Tb_*_1hr_${YEAR}${MONTH}*.nc"

        ls ${PR_FILES} >/dev/null 2>&1 || continue
        ls ${TB_FILES} >/dev/null 2>&1 || continue

        echo "Merging ${YEAR}-${MONTH}"

        CDO mergetime ${PR_FILES} "${DIR_II}/pr/pr_${DOMAIN}_${YEAR}${MONTH}.nc"
        CDO mergetime ${TB_FILES} "${DIR_II}/Tb/Tb_${DOMAIN}_${YEAR}${MONTH}.nc"
	CDO merge ${DIR_II}/pr/pr_${DOMAIN}_${YEAR}${MONTH}.nc ${DIR_II}/Tb/Tb_${DOMAIN}_${YEAR}${MONTH}.nc ${DIR_III}/${DOMAIN}_${EXP}_1hr_${YEAR}${MONTH}0100.nc
	CDO remapbil,${REGRID}/${DOMAIN}/grid.txt ${DIR_III}/${DOMAIN}_${EXP}_1hr_${YEAR}${MONTH}0100.nc ${DIR_III}/${DOMAIN}_${EXP}_1hr_${YEAR}${MONTH}0100_regrid.nc

    done
done

}
