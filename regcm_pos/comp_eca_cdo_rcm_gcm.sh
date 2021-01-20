#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '01/18/2021'
#__description__ = 'Calculate extreme index with ECA_CDO'

echo
echo "--------------- INIT CALCULATE INDEX REGCM AND HADGEM OUTPUT ----------------"

VAR="pr"
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
	cdo seldate,${YEAR}-01-01,${YEAR}-12-31 ${VAR}_amz_neb_${MODEL}_${EXP}_${DATA}_lonlat_seamask.nc ${VAR}_${YEAR}.nc

	echo 
	echo "2. Calculate precttot"
	cdo monsum ${VAR}_${YEAR}.nc ${VAR}_mon_${YEAR}.nc
	cdo yearsum ${VAR}_mon_${YEAR}.nc prectot_${YEAR}.nc

	echo 
	echo "3. Calculate r95ptot"
	cdo timsum ${VAR}_${YEAR}.nc timsum_${YEAR}.nc 
	cdo -L timpctl,95 ${VAR}_${YEAR}.nc -timmin ${VAR}_${YEAR}.nc -timmax ${VAR}_${YEAR}.nc q95_${YEAR}.nc 
	cdo -L -timsum -mul -ge ${VAR}_${YEAR}.nc q95_${YEAR}.nc ${VAR}_${YEAR}.nc total_ge_q95_${YEAR}.nc 
	cdo -L mulc,100 -div total_ge_q95_${YEAR}.nc timsum_${YEAR}.nc r95p_${YEAR}.nc

	echo 
	echo "4. Calculate r99ptot"
	cdo -L timpctl,99 ${VAR}_${YEAR}.nc -timmin ${VAR}_${YEAR}.nc -timmax ${VAR}_${YEAR}.nc q99_${YEAR}.nc 
	cdo -L -timsum -mul -ge ${VAR}_${YEAR}.nc q99_${YEAR}.nc ${VAR}_${YEAR}.nc total_ge_q99_${YEAR}.nc 
	cdo -L mulc,100 -div total_ge_q99_${YEAR}.nc timsum_${YEAR}.nc r99p_${YEAR}.nc

	echo 
	echo "5. Calculate rx1day"
	cdo -s eca_rx1day,m ${VAR}_${YEAR}.nc rx1_mon_${YEAR}.nc
	cdo yearmean rx1_mon_${YEAR}.nc rx1day_${YEAR}.nc

	echo 
	echo "6. Calculate rx5day"
	cdo -s eca_rx5day,50 ${VAR}_${YEAR}.nc rx5day_${YEAR}.nc

	echo 
	echo "7. Calculate sdii"
	cdo eca_sdii ${VAR}_${YEAR}.nc sdii_${YEAR}.nc

	echo 
	echo "8. Calculate cdd"
	cdo eca_cdd ${VAR}_${YEAR}.nc cdd_${YEAR}.nc

	echo 
	echo "9. Calculate cwd"
	cdo eca_cwd ${VAR}_${YEAR}.nc cwd_${YEAR}.nc

	echo 
	echo "10. Calculate r10mm"
	cdo eca_r10mm ${VAR}_${YEAR}.nc r10mm_${YEAR}.nc

	echo 
	echo "11. Calculate cwd"
	cdo eca_r20mm ${VAR}_${YEAR}.nc r20mm_${YEAR}.nc

done

echo 
echo "12. Concatenate data"
cdo cat prectot_*.nc eca_prectot_amz_neb_${MODEL}_${EXP}_yr_${DATA}_lonlat.nc
cdo cat r95p_*.nc eca_r95p_amz_neb_${MODEL}_${EXP}_yr_${DATA}_lonlat.nc
cdo cat r99p_*.nc eca_r99p_amz_neb_${MODEL}_${EXP}_yr_${DATA}_lonlat.nc
cdo cat rx1day_*.nc eca_rx1day_amz_neb_${MODEL}_${EXP}_yr_${DATA}_lonlat.nc
cdo cat rx5day_*.nc eca_rx5day_amz_neb_${MODEL}_${EXP}_yr_${DATA}_lonlat.nc
cdo cat sdii_*.nc eca_sdii_amz_neb_${MODEL}_${EXP}_yr_${DATA}_lonlat.nc
cdo cat cdd_*.nc eca_cdd_amz_neb_${MODEL}_${EXP}_yr_${DATA}_lonlat.nc
cdo cat cwd_*.nc eca_cwd_amz_neb_${MODEL}_${EXP}_yr_${DATA}_lonlat.nc
cdo cat r10mm_*.nc eca_r10mm_amz_neb_${MODEL}_${EXP}_yr_${DATA}_lonlat.nc
cdo cat r20mm_*.nc eca_r20mm_amz_neb_${MODEL}d_${EXP}_yr_${DATA}_lonlat.nc

echo 
echo "13. Delete files"
rm prectot*
rm pr_1*.nc
rm pr_2*.nc
rm r95p*
rm r99p*
rm rx1d*
rm rx5d*
rm sdii*
rm cdd*
rm cwd*
rm r10mm*
rm r20mm*
rm timsum*
rm q9*
rm total*
rm *mon*

echo
echo "--------------- END CALCULATE INDEX REGCM AND HADGEM OUTPUT ----------------"


