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
#__description__ = 'Calculate the freq/int of RegCM5 with CDO'
 
{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="EUR-11"

YR="2000-2009"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

VAR="pr"
FOLDER_LIST="NoTo-EUR WSM5-EUR WSM7-EUR WDM7-EUR"

echo
echo "--------------- INIT POSTPROCESSING MODEL ----------------"

for FOLDER in ${FOLDER_LIST[@]}; do

    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/${FOLDER}"
    DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/postproc/rcm"
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
    CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${FOLDER}_${YR}.nc
    
    echo
    echo "3. Convert unit"
    CDO -b f32 mulc,86400 ${VAR}_${FOLDER}_${YR}.nc ${VAR}_RegCM5_${FOLDER}_${YR}.nc
    
    echo
    echo "4. Frequency and intensity by season"
    for SEASON in ${SEASON_LIST[@]}; do

	CDO selseas,${SEASON} ${VAR}_RegCM5_${FOLDER}_${YR}.nc ${VAR}_RegCM5_${FOLDER}_${SEASON}_${YR}.nc

        CDO mulc,100 -histfreq,1,100000 ${VAR}_RegCM5_${FOLDER}_${SEASON}_${YR}.nc ${VAR}_freq_RegCM5_${FOLDER}_${SEASON}_${YR}.nc
        ${BIN}/./regrid ${VAR}_freq_RegCM5_${FOLDER}_${SEASON}_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil

        CDO histmean,1,100000 ${VAR}_RegCM5_${FOLDER}_${SEASON}_${YR}.nc ${VAR}_int_RegCM5_${FOLDER}_${SEASON}_${YR}.nc
	${BIN}/./regrid ${VAR}_int_RegCM5_${FOLDER}_${SEASON}_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil

    done

    echo 
    echo "5. Delete files"
    rm *0100.nc
    rm *${YR}.nc

done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
