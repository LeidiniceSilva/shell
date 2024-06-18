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

YR="2000-2000"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

EXP="EUR-11"
DATASET="ERA5"
VAR_LIST="cc clwc ciwc"

DIR_IN="/marconi/home/userexternal/mdasilva/OBS"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/EUR-11/post_evaluate/obs"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

for VAR in ${VAR_LIST[@]}; do

    echo
    echo "1. Select date"
    CDO selyear,${IYR}/${FYR} ${DIR_IN}/${DATASET}/${VAR}_${DATASET}_2000-2001.nc ${VAR}_${DATASET}_${IYR}.nc
    
    for MON in `seq -w 01 01`; do
	CDO selmonth,${MON} ${VAR}_${DATASET}_${IYR}.nc ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc
    done
	   
    echo
    echo "2. Regrid"
    ${BIN}/./regrid ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
    
    CDO sellonlatbox,1,16,40,50 ${VAR}_${EXP}_${DATASET}_${IYR}${MON}01_lonlat.nc ${VAR}_${EXP}_FPS_${DATASET}_${IYR}${MON}01_lonlat.nc

done

echo 
echo "Delete files"
rm *${IYR}${MON}01.nc

}
