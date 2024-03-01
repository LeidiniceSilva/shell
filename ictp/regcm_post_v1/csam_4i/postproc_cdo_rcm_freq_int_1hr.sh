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

TH=0.5
VAR="pr"
EXP="CSAM-4i_ECMWF-ERA5_evaluation"
DT="2018-2021"
SEASON_LIST="DJF MAM JJA SON"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/CSAM-4i/RCM"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/CSAM-4i/post_evaluate"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo 
echo "1. Merge time"
CDO mergetime ${DIR_IN}/reg_ictp/${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl1_v0_1hr* ${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl1_v0_1hr_${DT}.nc
CDO mergetime ${DIR_IN}/reg_ictp/${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl2_v0_1hr* ${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl2_v0_1hr_${DT}.nc
CDO mergetime ${DIR_IN}/reg_usp/${VAR}_${EXP}_r1i1p1f1_USP-RegCM471_v2_1hr* ${VAR}_${EXP}_r1i1p1f1_USP-RegCM471_v2_1hr_${DT}.nc
CDO mergetime ${DIR_IN}/wrf_ncar/${VAR}_${EXP}_r1i1p1f1_NCAR-WRF415_v1_1hr* ${VAR}_${EXP}_r1i1p1f1_NCAR-WRF415_v1_1hr_${DT}.nc
CDO mergetime ${DIR_IN}/wrf_ucan/${VAR}_${EXP}_r1i1p1f1_UCAN-WRF433_v1_1hr* ${VAR}_${EXP}_r1i1p1f1_UCAN-WRF433_v1_1hr_${DT}.nc

echo 
echo "2. Select data"
CDO seldate,2018-06-01,2021-05-31 ${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl1_v0_1hr_${DT}.nc ${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl1_1hr_${DT}.nc
CDO seldate,2018-06-01,2021-05-31 ${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl2_v0_1hr_${DT}.nc ${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl2_1hr_${DT}.nc
CDO seldate,2018-06-01,2021-05-31 ${VAR}_${EXP}_r1i1p1f1_USP-RegCM471_v2_1hr_${DT}.nc ${VAR}_${EXP}_r1i1p1f1_USP-RegCM471_1hr_${DT}.nc
CDO seldate,2018-06-01,2021-05-31 ${VAR}_${EXP}_r1i1p1f1_NCAR-WRF415_v1_1hr_${DT}.nc ${VAR}_${EXP}_r1i1p1f1_NCAR-WRF415_1hr_${DT}.nc
CDO seldate,2018-06-01,2021-05-31 ${VAR}_${EXP}_r1i1p1f1_UCAN-WRF433_v1_1hr_${DT}.nc ${VAR}_${EXP}_r1i1p1f1_UCAN-WRF433_1hr_${DT}.nc

echo
echo "3. Convert unit"
CDO -b f32 mulc,3600 ${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl1_1hr_${DT}.nc ${VAR}_${EXP}_ICTP-RegCM5pbl1_1hr_${DT}.nc
CDO -b f32 mulc,3600 ${VAR}_${EXP}_r1i1p1f1_ICTP-RegCM5pbl2_1hr_${DT}.nc ${VAR}_${EXP}_ICTP-RegCM5pbl2_1hr_${DT}.nc
CDO -b f32 mulc,3600 ${VAR}_${EXP}_r1i1p1f1_USP-RegCM471_1hr_${DT}.nc ${VAR}_${EXP}_USP-RegCM471_1hr_${DT}.nc
CDO -b f32 mulc,3600 ${VAR}_${EXP}_r1i1p1f1_NCAR-WRF415_1hr_${DT}.nc ${VAR}_${EXP}_NCAR-WRF415_1hr_${DT}.nc
CDO -b f32 mulc,3600 ${VAR}_${EXP}_r1i1p1f1_UCAN-WRF433_1hr_${DT}.nc ${VAR}_${EXP}_UCAN-WRF433_1hr_${DT}.nc

echo
echo "4. Frequency and intensity by season"
for SEASON in ${SEASON_LIST[@]}; do

    CDO selseas,${SEASON} ${VAR}_${EXP}_ICTP-RegCM5pbl1_1hr_${DT}.nc ${VAR}_${EXP}_ICTP-RegCM5pbl1_1hr_${SEASON}_${DT}.nc
    CDO selseas,${SEASON} ${VAR}_${EXP}_ICTP-RegCM5pbl2_1hr_${DT}.nc ${VAR}_${EXP}_ICTP-RegCM5pbl2_1hr_${SEASON}_${DT}.nc
    CDO selseas,${SEASON} ${VAR}_${EXP}_USP-RegCM471_1hr_${DT}.nc ${VAR}_${EXP}_USP-RegCM471_1hr_${SEASON}_${DT}.nc   
    CDO selseas,${SEASON} ${VAR}_${EXP}_NCAR-WRF415_1hr_${DT}.nc ${VAR}_${EXP}_NCAR-WRF415_1hr_${SEASON}_${DT}.nc 
    CDO selseas,${SEASON} ${VAR}_${EXP}_UCAN-WRF433_1hr_${DT}.nc ${VAR}_${EXP}_UCAN-WRF433_1hr_${SEASON}_${DT}.nc    
        
    CDO mulc,100 -histfreq,${TH},100000 ${VAR}_${EXP}_ICTP-RegCM5pbl1_1hr_${SEASON}_${DT}.nc ${VAR}_freq_${EXP}_ICTP-RegCM5pbl1_1hr_${SEASON}_${DT}_th${TH}.nc
    CDO mulc,100 -histfreq,${TH},100000 ${VAR}_${EXP}_ICTP-RegCM5pbl2_1hr_${SEASON}_${DT}.nc ${VAR}_freq_${EXP}_ICTP-RegCM5pbl2_1hr_${SEASON}_${DT}_th${TH}.nc
    CDO mulc,100 -histfreq,${TH},100000 ${VAR}_${EXP}_USP-RegCM471_1hr_${SEASON}_${DT}.nc ${VAR}_freq_${EXP}_USP-RegCM471_1hr_${SEASON}_${DT}_th${TH}.nc
    CDO mulc,100 -histfreq,${TH},100000 ${VAR}_${EXP}_NCAR-WRF415_1hr_${SEASON}_${DT}.nc ${VAR}_freq_${EXP}_NCAR-WRF415_1hr_${SEASON}_${DT}_th${TH}.nc
    CDO mulc,100 -histfreq,${TH},100000 ${VAR}_${EXP}_UCAN-WRF433_1hr_${SEASON}_${DT}.nc ${VAR}_freq_${EXP}_UCAN-WRF433_1hr_${SEASON}_${DT}_th${TH}.nc

    CDO histmean,${TH},100000 ${VAR}_${EXP}_ICTP-RegCM5pbl1_1hr_${SEASON}_${DT}.nc ${VAR}_int_${EXP}_ICTP-RegCM5pbl1_1hr_${SEASON}_${DT}_th${TH}.nc
    CDO histmean,${TH},100000 ${VAR}_${EXP}_ICTP-RegCM5pbl2_1hr_${SEASON}_${DT}.nc ${VAR}_int_${EXP}_ICTP-RegCM5pbl2_1hr_${SEASON}_${DT}_th${TH}.nc
    CDO histmean,${TH},100000 ${VAR}_${EXP}_USP-RegCM471_1hr_${SEASON}_${DT}.nc ${VAR}_int_${EXP}_USP-RegCM471_1hr_${SEASON}_${DT}_th${TH}.nc
    CDO histmean,${TH},100000 ${VAR}_${EXP}_NCAR-WRF415_1hr_${SEASON}_${DT}.nc ${VAR}_int_${EXP}_NCAR-WRF415_1hr_${SEASON}_${DT}_th${TH}.nc
    CDO histmean,${TH},100000 ${VAR}_${EXP}_UCAN-WRF433_1hr_${SEASON}_${DT}.nc ${VAR}_int_${EXP}_UCAN-WRF433_1hr_${SEASON}_${DT}_th${TH}.nc
    
    ${BIN}/./regrid ${VAR}_freq_${EXP}_ICTP-RegCM5pbl1_1hr_${SEASON}_${DT}_th${TH}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    ${BIN}/./regrid ${VAR}_freq_${EXP}_ICTP-RegCM5pbl2_1hr_${SEASON}_${DT}_th${TH}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil  
    ${BIN}/./regrid ${VAR}_freq_${EXP}_USP-RegCM471_1hr_${SEASON}_${DT}_th${TH}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    ${BIN}/./regrid ${VAR}_freq_${EXP}_NCAR-WRF415_1hr_${SEASON}_${DT}_th${TH}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    ${BIN}/./regrid ${VAR}_freq_${EXP}_UCAN-WRF433_1hr_${SEASON}_${DT}_th${TH}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

    ${BIN}/./regrid ${VAR}_int_${EXP}_ICTP-RegCM5pbl1_1hr_${SEASON}_${DT}_th${TH}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    ${BIN}/./regrid ${VAR}_int_${EXP}_ICTP-RegCM5pbl2_1hr_${SEASON}_${DT}_th${TH}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil  
    ${BIN}/./regrid ${VAR}_int_${EXP}_USP-RegCM471_1hr_${SEASON}_${DT}_th${TH}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    ${BIN}/./regrid ${VAR}_int_${EXP}_NCAR-WRF415_1hr_${SEASON}_${DT}_th${TH}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    ${BIN}/./regrid ${VAR}_int_${EXP}_UCAN-WRF433_1hr_${SEASON}_${DT}_th${TH}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    
done
  
echo 
echo "5. Delete files"
rm *_1hr_${DT}.nc
rm *_${DT}_th${TH}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}

