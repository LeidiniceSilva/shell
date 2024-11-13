#!/bin/bash

#SBATCH -N 1 
#SBATCH -t 24:00:00
#SBATCH -J Postproc
#SBATCH --qos=qos_prio
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p long

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the RegCM5 output with CDO'

# load required modules
module purge
source /opt-ictp/ESMF/env202108
set -e

{

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="2000-2000"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

EXP="EUR-11"
DATASET=$1

DIR_IN="/home/mda_silv/users/OBS"
DIR_OUT="/home/mda_silv/scratch/EUR-11/postproc/obs"
BIN="/home/mda_silv/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

if [ ${DATASET} == 'CPC' ]
then
echo 
echo "------------------------------- INIT POSTPROCESSING DATASET -------------------------------"

VAR="precip"

echo
echo "1. Select date"
CDO selyear,${IYR} ${DIR_IN}/${DATASET}/cpc.day.1979-2021.nc ${VAR}_${EXP}_${DATASET}_${IYR}.nc

for MON in `seq -w 01 01`; do
	CDO selmonth,${MON} ${VAR}_${EXP}_${DATASET}_${IYR}.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc
	
	echo
	echo "2. Calculate mon mean"
	CDO monmean ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}.nc

	echo
	echo "3. Calculate p99"
	CDO timmin ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_min.nc
	CDO timmax ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_max.nc
	CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_min.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_max.nc p99_${EXP}_${DATASET}_${IYR}${MON}01.nc
  
	echo
	echo "4. Frequency and intensity by season"
	CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_freq_${EXP}_${DATASET}_${IYR}${MON}01.nc
	CDO histmean,1,100000 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_int_${EXP}_${DATASET}_${IYR}${MON}01.nc

	echo
	echo "5. Regrid"
	${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_${IYR}${MON}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	${BIN}/./regrid p99_${EXP}_${DATASET}_${IYR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	${BIN}/./regrid ${VAR}_freq_${EXP}_${DATASET}_${IYR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	${BIN}/./regrid ${VAR}_int_${EXP}_${DATASET}_${IYR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	
	echo
	echo "6. Select domain"	
	CDO sellonlatbox,1,16,40,50 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_lonlat.nc ${VAR}_${EXP}_FPS_${DATASET}_${IYR}${MON}01_lonlat.nc
done

elif [ ${DATASET} == 'ERA5' ]
then
echo 
echo "------------------------------- INIT POSTPROCESSING DATASET -------------------------------"

VAR="tp"

echo
echo "1. Select date"
CDO selyear,${IYR} ${DIR_IN}/${DATASET}/tp_ERA5_2000-2009.nc ${VAR}_${DATASET}_1hr_${IYR}.nc

for MON in `seq -w 01 01`; do
	CDO selmonth,${MON} ${VAR}_${DATASET}_1hr_${IYR}.nc ${VAR}_${DATASET}_1hr_${IYR}${MON}01.nc
	
	echo
	echo "2. Calculate mon mean"
	CDO mulc,1000 ${VAR}_${DATASET}_1hr_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}0100.nc
	CDO daysum ${VAR}_${EXP}_${DATASET}_${IYR}${MON}0100.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc
	CDO monmean ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}.nc

	echo
	echo "3. Calculate p99"
	CDO timmin ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_min.nc
	CDO timmax ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_max.nc
	CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_min.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_max.nc p99_${EXP}_${DATASET}_${IYR}${MON}01.nc
  
	echo
	echo "4. Frequency and intensity by season"
	CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_freq_${EXP}_${DATASET}_${IYR}${MON}01.nc
	CDO histmean,1,100000 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_int_${EXP}_${DATASET}_${IYR}${MON}01.nc

	echo
	echo "5. Regrid"
	${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_${IYR}${MON}0100.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_${IYR}${MON}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	${BIN}/./regrid p99_${EXP}_${DATASET}_${IYR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	${BIN}/./regrid ${VAR}_freq_${EXP}_${DATASET}_${IYR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	${BIN}/./regrid ${VAR}_int_${EXP}_${DATASET}_${IYR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil

	echo
	echo "6. Select domain"	
	CDO sellonlatbox,1,16,40,50 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}0100_lonlat.nc ${VAR}_${EXP}_FPS_${DATASET}_${IYR}${MON}01_lonlat.nc
	CDO sellonlatbox,1,16,40,50 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_lonlat.nc ${VAR}_${EXP}_FPS_${DATASET}_${IYR}${MON}01_lonlat.nc
done

else
echo 
echo "------------------------------- INIT POSTPROCESSING DATASET -------------------------------"

VAR="rr"

echo
echo "1. Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/rr.nc ${VAR}_${EXP}_${DATASET}_${IYR}.nc

for MON in `seq -w 01 01`; do
	CDO selmonth,${MON} ${VAR}_${EXP}_${DATASET}_${IYR}.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc
	
	echo
	echo "2. Calculate mon mean"
	CDO monmean ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}.nc

	echo
	echo "3. Calculate p99"
	CDO timmin ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_min.nc
	CDO timmax ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_max.nc
	CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_min.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_max.nc p99_${EXP}_${DATASET}_${IYR}${MON}01.nc
  
	echo
	echo "4. Frequency and intensity by season"
	CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_freq_${EXP}_${DATASET}_${IYR}${MON}01.nc
	CDO histmean,1,100000 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_int_${EXP}_${DATASET}_${IYR}${MON}01.nc

	echo
	echo "5. Regrid"
	${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_${IYR}${MON}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	${BIN}/./regrid p99_${EXP}_${DATASET}_${IYR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	${BIN}/./regrid ${VAR}_freq_${EXP}_${DATASET}_${IYR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
	${BIN}/./regrid ${VAR}_int_${EXP}_${DATASET}_${IYR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil

	echo
	echo "6. Select domain"	
	CDO sellonlatbox,1,16,40,50 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_lonlat.nc ${VAR}_${EXP}_FPS_${DATASET}_${IYR}${MON}01_lonlat.nc
done

fi

echo 
echo "7. Delete files"
rm *_${EXP}_${DATASET}_${IYR}.nc
rm *_${EXP}_${DATASET}_${IYR}${MON}01.nc
rm *_${EXP}_${DATASET}_${IYR}${MON}01_min.nc
rm *_${EXP}_${DATASET}_${IYR}${MON}01_max.nc
rm *_${EXP}_${DATASET}_${IYR}${MON}.nc

}
