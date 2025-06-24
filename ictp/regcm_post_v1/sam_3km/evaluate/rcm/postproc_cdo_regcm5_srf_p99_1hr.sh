#!/bin/bash

#SBATCH -A ICT25_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the RegCM5 output with CDO'

{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="2018-2021"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

EXP="SAM-3km"
VAR="pr"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/test/output"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/evaluate/rcm"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "Select variable: ${VAR}"
for YEAR in `seq -w ${IYR} ${FYR}`; do
    for MON in `seq -w 01 12`; do
        CDO selname,${VAR} ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
    done
done

echo 
echo "Concatenate date: ${YR}"
CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${EXP}_1hr_${YR}.nc
 
echo
echo "Convert unit"
CDO -b f32 mulc,3600 ${VAR}_${EXP}_1hr_${YR}.nc ${VAR}_${EXP}_RegCM5_1hr_${YR}.nc

echo
echo "Calculate p99"
CDO timmin ${VAR}_${EXP}_RegCM5_1hr_${YR}.nc ${VAR}_${EXP}_RegCM5_1hr_${YR}_min.nc
CDO timmax ${VAR}_${EXP}_RegCM5_1hr_${YR}.nc ${VAR}_${EXP}_RegCM5_1hr_${YR}_max.nc
CDO timpctl,99 ${VAR}_${EXP}_RegCM5_1hr_${YR}.nc ${VAR}_${EXP}_RegCM5_1hr_${YR}_min.nc ${VAR}_${EXP}_RegCM5_1hr_${YR}_max.nc p99_${EXP}_RegCM5_1hr_${YR}.nc
  
echo
echo "Regrid variable"
${BIN}/./regrid p99_${EXP}_RegCM5_1hr_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo 
echo "Delete files"
rm *0100.nc
rm *_${YR}.nc
rm ${VAR}_${EXP}_RegCM5_1hr_${YR}_min.nc
rm ${VAR}_${EXP}_RegCM5_1hr_${YR}_max.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
