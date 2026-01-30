#!/bin/bash

#SBATCH -A CMPNS_ictpclim
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jan 30, 2026'
#__description__ = 'Posprocessing the RegCM5 output with CDO'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

INST="RegCM5-ERA5_ICTP"
EXP="SAM-12"

YR="1970-1970"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

if [ ${INST} == 'RegCM5-ERA5_ICTP' ]
then
DIR_IN="/leonardo/home/userexternal/mdasilva/reg-era5"
else
DIR_IN="/leonardo_work/ICT25_ESP/nzazulie/SAM-12/ERA5/NoTo-SouthAmerica"
fi
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/${EXP}/postproc/rcm"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo 
echo "Select variables"
VAR_LIST="pr tas"
for VAR in ${VAR_LIST[@]}; do
    for YEAR in `seq -w ${IYR} ${FYR}`; do
        for MON in `seq -w 01 01`; do
            CDO selname,${VAR} ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc   
    	    if [ ${VAR} == 'pr' ]
    	    then
	    CDO -b f32 mulc,3600 ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_${INST}_${YEAR}${MON}0100.nc 
	    CDO daysum ${VAR}_${EXP}_${INST}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_${INST}_day_${YEAR}${MON}.nc
	    CDO monmean ${VAR}_${EXP}_${INST}_day_${YEAR}${MON}.nc ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc
     	    CDO timmin ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc ${VAR}_${EXP}_${INST}_${YEAR}${MON}_min.nc
	    CDO timmax ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc ${VAR}_${EXP}_${INST}_${YEAR}${MON}_max.nc
	    CDO timpctl,99 ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc ${VAR}_${EXP}_${INST}_${YEAR}${MON}_min.nc ${VAR}_${EXP}_${INST}_${YEAR}${MON}_max.nc p99_${EXP}_${INST}_${YEAR}${MON}.nc
	    CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc ${VAR}_freq_${EXP}_${INST}_${YEAR}${MON}.nc
	    CDO histmean,1,100000 ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc ${VAR}_int_${EXP}_${INST}_${YEAR}${MON}.nc
            ${BIN}/./regrid ${VAR}_${EXP}_${INST}_day_${YEAR}${MON}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
            ${BIN}/./regrid ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
            ${BIN}/./regrid p99_${EXP}_${INST}_${YEAR}${MON}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
            ${BIN}/./regrid ${VAR}_freq_${EXP}_${INST}_${YEAR}${MON}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
            ${BIN}/./regrid ${VAR}_int_${EXP}_${INST}_${YEAR}${MON}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
            else
	    CDO -b f32 subc,273.15 ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_${INST}_${YEAR}${MON}0100.nc 
	    CDO monmean ${VAR}_${EXP}_${INST}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc 
            ${BIN}/./regrid ${VAR}_${EXP}_${INST}_mon_${YEAR}${MON}.nc -57.89861,18.49594,0.11 -105.8313,-16.58986,0.11 bil
	    fi	
        done
    done 
done

echo 
echo "Delete files"
rm *0100.nc
rm *01.nc
rm *min.nc
rm *max.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
