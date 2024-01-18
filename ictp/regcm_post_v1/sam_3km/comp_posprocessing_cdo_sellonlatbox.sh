#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the OBS datasets with CDO'

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="SAM-3km"
DATASET="RegCM5"
DT="2018-2021"
SEASON_LIST="DJF MAM JJA SON"

DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/sam_3km/post"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "1.2. Select sesa domain"
for SEASON in ${SEASON_LIST[@]}; do

	if [ ${DATASET} == 'RegCM5' ]
	then
		CDO sellonlatbox,-65,-52,-35,-24 cl_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc cl_SESA_${DATASET}_${SEASON}_${DT}_lonlat.nc
		CDO sellonlatbox,-65,-52,-35,-24 cli_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc cli_SESA_${DATASET}_${SEASON}_${DT}_lonlat.nc
		CDO sellonlatbox,-65,-52,-35,-24 clw_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc clw_SESA_${DATASET}_${SEASON}_${DT}_lonlat.nc
	else
		CDO sellonlatbox,-65,-52,-35,-24 cc_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc cc_SESA_${DATASET}_${SEASON}_${DT}_lonlat.nc
		CDO sellonlatbox,-65,-52,-35,-24 ciwc_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc ciwc_SESA_${DATASET}_${SEASON}_${DT}_lonlat.nc
		CDO sellonlatbox,-65,-52,-35,-24 clwc_${EXP}_${DATASET}_${SEASON}_${DT}_lonlat.nc clwc_SESA_${DATASET}_${SEASON}_${DT}_lonlat.nc
	fi
					
done

#CDO sellonlatbox,-65,-45,-40,-20 pr_${EXP}_RegCM5_day_${DT}_lonlat.nc pr_SESA_RegCM5_day_${DT}_lonlat.nc
#CDO sellonlatbox,-65,-45,-40,-20 pr_${EXP}_RegCM5_mon_${DT}_lonlat.nc pr_SESA_RegCM5_mon_${DT}_lonlat.nc
#CDO sellonlatbox,-65,-45,-40,-20 tas_${EXP}_RegCM5_mon_${DT}_lonlat.nc tas_SESA_RegCM5_mon_${DT}_lonlat.nc
#CDO sellonlatbox,-65,-45,-40,-20 tp_${EXP}_ERA5_day_${DT}_lonlat.nc tp_SESA_ERA5_day_${DT}_lonlat.nc
#CDO sellonlatbox,-65,-45,-40,-20 tp_${EXP}_ERA5_mon_${DT}_lonlat.nc tp_SESA_ERA5_mon_${DT}_lonlat.nc
#CDO sellonlatbox,-65,-45,-40,-20 t2m_${EXP}_ERA5_mon_${DT}_lonlat.nc t2m_SESA_ERA5_mon_${DT}_lonlat.nc
		
}
