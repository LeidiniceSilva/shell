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
#__description__ = 'Calculate the 1hr freq/int of RegCM5 with CDO'

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="2018-2021"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

VAR="pr"
EXP="SAM-3km"

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
for YEAR in `seq -w ${IYR} ${FYR}`; do
    for MON in `seq -w 01 12`; do
        CDO selname,${VAR} ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
    done
done

echo 
echo "2. Concatenate date: ${YR}"
CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${EXP}_1hr_${YR}.nc
 
echo
echo "3. Convert unit"
CDO -b f32 mulc,3600 ${VAR}_${EXP}_1hr_${YR}.nc ${VAR}_${EXP}_RegCM5_1hr_${YR}.nc
${BIN}/./regrid ${VAR}_${EXP}_RegCM5_1hr_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo 
echo "4. Delete files"
rm *0100.nc
rm *_${YR}.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
