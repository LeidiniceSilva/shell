#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jan 02, 2024'
#__description__ = 'Posprocessing the RegCM5 output with CDO'

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="SAM-3km-cyclone"
YEAR="2023"
DT="2023060100-2023083100"
VAR_LIST="hus ta ua va wa"
#VAR_LIST="hfss hfls hus pr psl sfcWind ta tas ua uas va vas wa"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km-cyclone/NoTo-SAM"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km-cyclone/post"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "1. Select variable: ${VAR}"
    for MON in `seq -w 06 08`; do
    	if [ ${VAR} = hus  ]
	then
	CDO selname,${VAR} ${DIR_IN}/pressure/${EXP}_ATM.${YEAR}${MON}0100_pressure.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	CDO sellevel,200,500,850,925 ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100_lev.nc
    	elif [ ${VAR} = ta  ]
	then
	CDO selname,${VAR} ${DIR_IN}/pressure/${EXP}_ATM.${YEAR}${MON}0100_pressure.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	CDO sellevel,200,500,850,925 ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100_lev.nc
    	elif [ ${VAR} = ua  ]
	then
	CDO selname,${VAR} ${DIR_IN}/pressure/${EXP}_ATM.${YEAR}${MON}0100_pressure.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	CDO sellevel,200,500,850,925 ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100_lev.nc	
    	elif [ ${VAR} = va  ]
	then
	CDO selname,${VAR} ${DIR_IN}/pressure/${EXP}_ATM.${YEAR}${MON}0100_pressure.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	CDO sellevel,200,500,850,925 ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100_lev.nc
    	elif [ ${VAR} = wa  ]
	then
	CDO selname,${VAR} ${DIR_IN}/pressure/${EXP}_ATM.${YEAR}${MON}0100_pressure.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	CDO sellevel,200,500,850,925 ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100_lev.nc	
	else
	CDO selname,${VAR} ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	fi
    done
    
    echo
    echo "2. Concatenate variable"
    if [ ${VAR} = hus  ]
    then
    CDO mergetime ${VAR}_${EXP}_*0100_lev.nc ${VAR}_${EXP}_ECMWF_ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_6h_${DT}.nc
    elif [ ${VAR} = ta  ]
    then
    CDO mergetime ${VAR}_${EXP}_*0100_lev.nc ${VAR}_${EXP}_ECMWF_ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_6h_${DT}.nc
    elif [ ${VAR} = ua  ]
    then
    CDO mergetime ${VAR}_${EXP}_*0100_lev.nc ${VAR}_${EXP}_ECMWF_ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_6h_${DT}.nc
    elif [ ${VAR} = va  ]
    then
    CDO mergetime ${VAR}_${EXP}_*0100_lev.nc ${VAR}_${EXP}_ECMWF_ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_6h_${DT}.nc
    elif [ ${VAR} = wa  ]
    then
    CDO mergetime ${VAR}_${EXP}_*0100_lev.nc ${VAR}_${EXP}_ECMWF_ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_6h_${DT}.nc
    else
    CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${EXP}_ECMWF_ERA5_evaluation_r1i1p1f1_ICTP-RegCM5_3h_${DT}.nc
    fi

done

echo 
echo "3. Delete files"
rm *_${EXP}_*0100.nc
rm *_${EXP}_*0100_lev.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
