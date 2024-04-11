#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the OBS datasets with CDO'

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="2018-2018"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

VAR="precip"
EXP="SAM-3km"
DATASET="CPC"

DIR_IN="/marconi/home/userexternal/mdasilva/OBS"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km_v5/post/obs"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "1. Select date"
CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/cpc.day.1979-2021.nc ${VAR}_${EXP}_${DATASET}_${IYR}.nc

for MON in `seq -w 01 09`; do

	CDO selmonth,${MON} ${VAR}_${EXP}_${DATASET}_${IYR}.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc

	echo
	echo "2. Calculate p99"
	CDO timmin ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_min.nc
	CDO timmax ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_max.nc
	CDO timpctl,99 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_min.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_max.nc p99_${EXP}_${DATASET}_${IYR}${MON}01.nc
  
	echo
	echo "3. Frequency and intensity by season"
	CDO mulc,100 -histfreq,1,100000 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_freq_${EXP}_${DATASET}_${IYR}${MON}01.nc
	
	CDO histmean,1,100000 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc ${VAR}_int_${EXP}_${DATASET}_${IYR}${MON}01.nc

	echo
	echo "4. Regrid"
	${BIN}/./regrid p99_${EXP}_${DATASET}_${IYR}${MON}01.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
	${BIN}/./regrid ${VAR}_freq_${EXP}_${DATASET}_${IYR}${MON}01.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
	${BIN}/./regrid ${VAR}_int_${EXP}_${DATASET}_${IYR}${MON}01.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
	
done

echo
echo "r. Delet files"
rm *_SAM-3km_${DATASET}_${IYR}${MON}0*.nc

}
