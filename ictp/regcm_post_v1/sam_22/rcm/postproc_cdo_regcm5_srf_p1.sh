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
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 
{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="SAM-22"

YR="1970-1971"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

VAR_LIST="pr tas clt"
FOLDER_LIST="srfsat"

echo
echo "--------------- INIT POSTPROCESSING MODEL ----------------"

for FOLDER in ${FOLDER_LIST[@]}; do

    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/${EXP}/${FOLDER}"
    DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/${EXP}/postproc/rcm"
    BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}

    for VAR in ${VAR_LIST[@]}; do
    
        echo
        echo "1. Select variable: ${VAR}"
        for YEAR in `seq -w ${IYR} ${FYR}`; do
            for MON in `seq -w 01 12`; do
        	if [ ${VAR} = 'pr' ] || [ ${VAR} = 'tas' ]
        	then
                CDO selname,${VAR} ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
		else
                CDO selname,${VAR} ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
		fi  
            done
        done
    
        echo 
        echo "2. Concatenate data"
        CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${EXP}_${FOLDER}_${YR}.nc
           
        echo
        echo "3. Convert unit"
        if [ ${VAR} = 'pr' ]
        then
        CDO -b f32 mulc,86400 ${VAR}_${EXP}_${FOLDER}_${YR}.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_day_${YR}.nc
        elif [ ${VAR} = 'tas' ]
        then
        CDO -b f32 subc,273.15 ${VAR}_${EXP}_${FOLDER}_${YR}.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_day_${YR}.nc
	else
	CDO daymean ${VAR}_${EXP}_${FOLDER}_${YR}.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_day_${YR}.nc
        fi

        echo
        echo "4. Seasonal avg and Regrid"
        for SEASON in ${SEASON_LIST[@]}; do
            CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${FOLDER}_RegCM5_day_${YR}.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_${SEASON}_${YR}.nc
	    ${BIN}/./regrid ${VAR}_${EXP}_${FOLDER}_RegCM5_${SEASON}_${YR}.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil
        done
    done
    
    echo 
    echo "5. Delete files"
    rm *0100.nc
    rm *${YR}.nc

done

echo
echo "--------------- THE END POSTPROCESSING MODEL ----------------"

}
