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
#__date__        = 'Nov 20, 2023'
#__description__ = 'Calculate the 1hr p99 of RegCM5 with CDO'

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

TH=0.5
VAR="pr"
EXP="SAM-3km"
DT="2018-2021"
SEASON_LIST="DJF MAM JJA SON"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/NoTo-SAM"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_evaluate/rcm"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "1. Select variable: ${VAR}"
for YEAR in `seq -w 2018 2021`; do
    for MON in `seq -w 01 12`; do
        CDO selname,${VAR} ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
    done
done

echo 
echo "2. Merge time: ${DT}"
CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${EXP}_1hr_${DT}.nc
 
echo
echo "3. Convert unit"
CDO -b f32 mulc,3600 ${VAR}_${EXP}_1hr_${DT}.nc ${VAR}_${EXP}_RegCM5_1hr_${DT}.nc

echo
echo "4. Frequency and intensity by season"
for SEASON in ${SEASON_LIST[@]}; do
    CDO selseas,${SEASON} ${VAR}_${EXP}_RegCM5_1hr_${DT}.nc ${VAR}_${EXP}_RegCM5_1hr_${SEASON}_${DT}.nc
    
    CDO mulc,100 -histfreq,${TH},100000 ${VAR}_${EXP}_RegCM5_1hr_${SEASON}_${DT}.nc ${VAR}_freq_${EXP}_RegCM5_1hr_${SEASON}_${DT}_th${TH}.nc
    ${BIN}/./regrid ${VAR}_freq_${EXP}_RegCM5_1hr_${SEASON}_${DT}_th${TH}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

    CDO histmean,${TH},100000 ${VAR}_${EXP}_RegCM5_1hr_${SEASON}_${DT}.nc ${VAR}_int_${EXP}_RegCM5_1hr_${SEASON}_${DT}_th${TH}.nc
    ${BIN}/./regrid ${VAR}_int_${EXP}_RegCM5_1hr_${SEASON}_${DT}_th${TH}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

done

echo 
echo "6. Delete files"
rm *0100.nc
rm *_${DT}.nc
rm *_${DT}_th${TH}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
