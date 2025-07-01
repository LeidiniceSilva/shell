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

EXP="EUR-11"

YR="2000-2009"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

VAR_LIST="pr"
FOLDER_LIST="WDM7-EUR"

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
                CDO selname,${VAR} ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc  
            done
        done
    
        echo 
        echo "2. Concatenate data"
        CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${FOLDER}_${YR}.nc
           
        echo
        echo "3. Convert unit"
        CDO -b f32 mulc,3600 ${VAR}_${FOLDER}_${YR}.nc ${VAR}_RegCM5_${FOLDER}_1hr_${YR}.nc
	CDO daysum ${VAR}_RegCM5_${FOLDER}_1hr_${YR}.nc ${VAR}_RegCM5_${FOLDER}_day_${YR}.nc 
	CDO monmean ${VAR}_RegCM5_${FOLDER}_day_${YR}.nc ${VAR}_RegCM5_${FOLDER}_mon_${YR}.nc 
	
	echo
	echo "4. Hourly mean"
	for HR in `seq -w 00 23`; do
            CDO selhour,${HR} ${VAR}_RegCM5_${FOLDER}_1hr_${YR}.nc ${VAR}_RegCM5_${FOLDER}_${HR}hr_${YR}.nc
            CDO timmean ${VAR}_RegCM5_${FOLDER}_${HR}hr_${YR}.nc ${VAR}_RegCM5_${FOLDER}_${HR}hr_${YR}_timmean.nc
	done
       
	echo
       	echo "5. Diurnal cycle"
	CDO mergetime ${VAR}_RegCM5_${FOLDER}_*hr_${YR}_timmean.nc ${VAR}_RegCM5_${FOLDER}_diurnal_cycle_${YR}.nc
	
	echo
	echo "6. Regrid output"
       	${BIN}/./regrid ${VAR}_RegCM5_${FOLDER}_1hr_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
       	${BIN}/./regrid ${VAR}_RegCM5_${FOLDER}_day_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
       	${BIN}/./regrid ${VAR}_RegCM5_${FOLDER}_mon_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
       	${BIN}/./regrid ${VAR}_RegCM5_${FOLDER}_diurnal_cycle_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil

	CDO sellonlatbox,1,16,40,50 ${VAR}_RegCM5_${FOLDER}_1hr_${YR}_lonlat.nc ${VAR}_RegCM5_${FOLDER}-FPS_1hr_${YR}_lonlat.nc
	CDO sellonlatbox,1,16,40,50 ${VAR}_RegCM5_${FOLDER}_day_${YR}_lonlat.nc ${VAR}_RegCM5_${FOLDER}-FPS_day_${YR}_lonlat.nc
	CDO sellonlatbox,1,16,40,50 ${VAR}_RegCM5_${FOLDER}_mon_${YR}_lonlat.nc ${VAR}_RegCM5_${FOLDER}-FPS_mon_${YR}_lonlat.nc
	CDO sellonlatbox,1,16,40,50 ${VAR}_RegCM5_${FOLDER}_diurnal_cycle_${YR}_lonlat.nc ${VAR}_RegCM5_${FOLDER}-FPS_diurnal_cycle_${YR}_lonlat.nc
    
        echo 
        echo "7. Delete files"
        rm *0100.nc
        rm *${YR}.nc
	rm *timmean.nc

    done
done

echo
echo "--------------- THE END POSTPROCESSING MODEL ----------------"

}
