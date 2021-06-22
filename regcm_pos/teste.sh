#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '01/18/2021'
#__description__ = 'Calculate extreme index with ECA_CDO'

echo
echo "--------------- INIT CALCULATE INDEX REGCM AND HADGEM OUTPUT ----------------"

DATA="1986-2005"
EXP="historical"
MODEL="RegCM47_had"
MODEL_DIR="rcm"
DIR="/home/nice/Documents/dataset/${MODEL_DIR}/eca"

echo
cd ${DIR}
echo ${DIR}

for YEAR in `seq -w 1986 2005`; do

	echo ${YEAR}
	echo "1. Select year"
	cdo seldate,${YEAR}-01-01,${YEAR}-12-31 pr_amz_neb_${MODEL}_${EXP}_${DATA}_lonlat_seamask.nc pr_${YEAR}.nc

	echo 
	echo "2. Calculate precttot"
	cdo monsum pr_${YEAR}.nc pr_mon_${YEAR}.nc
	cdo yearsum pr_mon_${YEAR}.nc prectot_${YEAR}.nc

done

echo 
echo "12. Concatenate data"
cdo cat prectot_*.nc eca_prectot_amz_neb_${MODEL}_${EXP}_yr_${DATA}_lonlat.nc


echo
echo "--------------- END CALCULATE INDEX REGCM AND HADGEM OUTPUT ----------------"


