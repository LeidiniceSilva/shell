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
#__date__        = 'Mar 12, 2024'
#__description__ = 'Calculate the p99 of RegCM5 with CDO'
 
{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="SAM-22"

YR="1970-1971"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

VAR="pr"
FOLDER_LIST="vfqr"

echo
echo "--------------- INIT POSTPROCESSING MODEL ----------------"

for FOLDER in ${FOLDER_LIST[@]}; do

    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/${EXP}/${FOLDER}"
    DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/${EXP}/postproc/rcm"
    BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}

    echo
    echo "1. Select variable: ${VAR}"
    for YEAR in `seq -w ${IYR} ${FYR}`; do
        for MON in `seq -w 01 12`; do
            CDO selname,${VAR} ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
        done
    done

    echo 
    echo "2. Concatenate data"
    CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${EXP}_${FOLDER}_${YR}.nc
    
    echo
    echo "3. Convert unit"
    CDO -b f32 mulc,86400 ${VAR}_${EXP}_${FOLDER}_${YR}.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_${YR}.nc
    
    echo
    echo "4. Calculate p99"
    CDO timmin ${VAR}_${EXP}_${FOLDER}_RegCM5_${YR}.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_${YR}_min.nc
    CDO timmax ${VAR}_${EXP}_${FOLDER}_RegCM5_${YR}.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_${YR}_max.nc
    CDO timpctl,99 ${VAR}_${EXP}_${FOLDER}_RegCM5_${YR}.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_${YR}_min.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_${YR}_max.nc p99_${EXP}_${FOLDER}_RegCM5_${YR}.nc
    
    echo
    echo "5. Regrid variable"
    ${BIN}/./regrid p99_${EXP}_${FOLDER}_RegCM5_${YR}.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil

    echo 
    echo "6. Delete files"
    rm *0100.nc
    rm *${YR}.nc
    rm *${YR}_min.nc
    rm *${YR}_max.nc

done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
