#!/bin/bash

#SBATCH -N 1 
#SBATCH -t 24:00:00
#SBATCH -A ICT23_ESP
#SBATCH --qos=qos_prio
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p skl_usr_prod

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Feb 26, 2024'
#__description__ = 'Calculate the 1hr p99 of RCM with CDO'

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

VAR="pr"
EXP="CSAM-4i_ECMWF-ERA5_evaluation"
DT="20180101-20211231"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/CSAM-4i"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_IN}
echo ${DIR_IN}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo 
echo "1. Merge time"
CDO mergetime ${DIR_IN}/RegCM5/${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl1_v0_1hr* ${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl1_v0_${DT}.nc
CDO mergetime ${DIR_IN}/RegCM5/${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl2_v0_1hr* ${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl2_v0_${DT}.nc
CDO mergetime ${DIR_IN}/RegCM4/${VAR}_${EXP}_r1i1p1f1_USP-RegCM471_v2_1hr* ${VAR}_${EXP}_r1i1p1f1_USP-RegCM471_v2_${DT}.nc
CDO mergetime ${DIR_IN}/WRF-NCAR/${VAR}_${EXP}_r1i1p1f1_NCAR-WRF415_v1_1hr* ${VAR}_${EXP}_r1i1p1f1_NCAR-WRF415_v1_${DT}.nc
CDO mergetime ${DIR_IN}/WRF-UCAN/${VAR}_${EXP}_r1i1p1f1_UCAN-WRF433_v1_1hr* ${VAR}_${EXP}_r1i1p1f1_UCAN-WRF433_v1_${DT}.nc

echo
echo "3. Convert unit"
CDO -b f32 mulc,3600 ${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl1_v0_${DT}.nc ${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl1_v0_1hr_${DT}.nc
CDO -b f32 mulc,3600 ${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl2_v0_${DT}.nc ${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl2_v0_1hr_${DT}.nc
CDO -b f32 mulc,3600 ${VAR}_${EXP}_r1i1p1f1_USP-RegCM471_v2_${DT}.nc ${VAR}_${EXP}_r1i1p1f1_USP-RegCM471_v2_1hr_${DT}.nc
CDO -b f32 mulc,3600 ${VAR}_${EXP}_r1i1p1f1_NCAR-WRF415_v1_${DT}.nc ${VAR}_${EXP}_r1i1p1f1_NCAR-WRF415_v1_1hr_${DT}.nc
CDO -b f32 mulc,3600 ${VAR}_${EXP}_r1i1p1f1_UCAN-WRF433_v1_${DT}.nc ${VAR}_${EXP}_r1i1p1f1_UCAN-WRF433_v1_1hr_${DT}.nc

echo 
echo "5. Delete files"
rm ${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl1_v0_${DT}.nc
rm ${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl2_v0_${DT}.nc
rm ${VAR}_${EXP}_r1i1p1f1_USP-RegCM471_v2_${DT}.nc
rm ${VAR}_${EXP}_r1i1p1f1_NCAR-WRF415_v1_${DT}.nc
rm ${VAR}_${EXP}_r1i1p1f1_UCAN-WRF433_v1_${DT}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}

