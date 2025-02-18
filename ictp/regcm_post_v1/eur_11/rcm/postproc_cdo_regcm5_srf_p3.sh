#!/bin/bash

#SBATCH -A ICT23_ESP_1
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

EXP="EUR-11"

YR="2000-2001"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

VAR_LIST="pr"
FOLDER_LIST="NoTo-Europe WSM5-Europe WSM7-Europe WDM7-Europe"

echo
echo "--------------- INIT POSTPROCESSING MODEL ----------------"

for FOLDER in ${FOLDER_LIST[@]}; do

    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/${FOLDER}"
    DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/postproc/rcm"
    BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}

    for VAR in ${VAR_LIST[@]}; do
    
        echo
        echo "1. Select variable: ${VAR}"
        for YEAR in `seq -w ${IYR} ${FYR}`; do
            for MON in `seq -w 01 12`; do
                CDO selname,${VAR} ${DIR_IN}/${EXP}_SHF.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc  
            done
        done
    
        echo 
        echo "2. Concatenate data"
        CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${EXP}_${FOLDER}_${YR}.nc
           
        echo
        echo "3. Convert unit"
        CDO -b f32 mulc,3600 ${VAR}_${EXP}_${FOLDER}_${YR}.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_1hr_${YR}.nc
	CDO daysum ${VAR}_${EXP}_${FOLDER}_RegCM5_1hr_${YR}.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_day_${YR}.nc
	CDO monmean ${VAR}_${EXP}_${FOLDER}_RegCM5_day_${YR}.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_mon_${YR}.nc 

	echo
	echo "4. Regrid output"
       	${BIN}/./regrid ${VAR}_${EXP}_${FOLDER}_RegCM5_1hr_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
       	${BIN}/./regrid ${VAR}_${EXP}_${FOLDER}_RegCM5_day_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
       	${BIN}/./regrid ${VAR}_${EXP}_${FOLDER}_RegCM5_mon_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	CDO sellonlatbox,1,16,40,50 ${VAR}_${EXP}_${FOLDER}_RegCM5_1hr_${YR}_lonlat.nc ${VAR}_${EXP}_FPS_${FOLDER}_RegCM5_1hr_${YR}_lonlat.nc 
	CDO sellonlatbox,1,16,40,50 ${VAR}_${EXP}_${FOLDER}_RegCM5_day_${YR}_lonlat.nc ${VAR}_${EXP}_FPS_${FOLDER}_RegCM5_day_${YR}_lonlat.nc 
	CDO sellonlatbox,1,16,40,50 ${VAR}_${EXP}_${FOLDER}_RegCM5_mon_${YR}_lonlat.nc ${VAR}_${EXP}_FPS_${FOLDER}_RegCM5_mon_${YR}_lonlat.nc 

        echo 
        echo "5. Delete files"
        rm *0100.nc
        rm *${YR}.nc

    done
done

echo
echo "--------------- THE END POSTPROCESSING MODEL ----------------"

}
