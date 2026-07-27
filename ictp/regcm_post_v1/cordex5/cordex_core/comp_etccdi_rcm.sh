#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J ETCCDI
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Compute ETCCDI indies using CDO-ECA'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

# Input files
INPUT="/data2/rose/sts-cordex-hyp2x/"
OUTPUT="/data/rose/out-leidinice/"
TMP="${OUTPUT}/tmp"
mkdir -p ${OUTPUT}
mkdir -p ${TMP}

# Variaveis regcm
PR="pr"
TASMIN="tasmin"

# Loop para processar ano a ano 
for year in {1970..2024}; do

  echo "Processing year ${year}"

    FILES=$(ls ${INPUT}/*STS*${year}*.nc 2>/dev/null)
    for file in ${FILES}; do

        name=$(basename ${file} .nc)
        cdo selname,${PR} ${file} ${TMP}/${name}_pr.nc
        CDO selname,${TASMIN} ${file} ${TMP}/${name}_tasmin.nc

    done

    CDO mergetime ${TMP}/*.${year}??????_pr.nc  ${TMP}/RegCM_Nor_pr_${year}.nc
    CDO mergetime ${TMP}/*.${year}??????_tasmin.nc ${TMP}/RegCM_Nor_tasmin_${year}.nc

    # RX1day (max 1-day prec)
    CDO mulc,86400 ${TMP}/RegCM_Nor_pr_${year}.nc ${TMP}/RegCM_Nor_pr_mmday_${year}.nc
    CDO eca_rx1day ${TMP}/RegCM_Nor_pr_mmday_${year}.nc ${OUTPUT}/RegCM_Nor_rx1day_${year}.nc

    # TN20 (mn2t > 20°C)
    CDO eca_tr,20 ${TMP}/RegCM_Nor_tasmin_${year}.nc ${OUTPUT}/RegCM_Nor_tn20_${year}.nc

    # Delete
    #rm -f ${TMP}/*${year}*_pr.nc
    #rm -f ${TMP}/*${year}*_tasmin.nc
    #rm -f ${TMP}/RegCM_Nor_pr_${year}.nc
    #rm -f ${TMP}/RegCM_Nor_tasmin_${year}.nc
    #rm -f ${TMP}/RegCM_Nor_pr_mmday_${year}.nc

done 

# Merge years 
CDO mergetime \
${OUTPUT}/RegCM_Nor_rx1day_[0-9][0-9][0-9][0-9].nc \
${OUTPUT}/RegCM_Nor_rx1day_1970_2024.nc

CDO mergetime \
${OUTPUT}/RegCM_Nor_tn20_[0-9][0-9][0-9][0-9].nc \
${OUTPUT}/RegCM_Nor_tn20_1970_2024.nc

# Delete
#rm -rf ${TMP}

}
