#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '01/18/2021'
#__description__ = 'Calculate extreme index with ECA_CDO'

echo
echo "--------------- INIT CALCULATE INDEX REGCM AND HADGEM OUTPUT ----------------"

DATA="1986-2005"
EXP="historical"
MODEL="HadGEM2-ES"
MODEL_DIR="gcm"
DIR="/home/nice/Documents/dataset/${MODEL_DIR}/eca"

echo
cd ${DIR}
echo ${DIR}

echo 
echo "1. Calculate txx"
cdo -yearmax tasmax_amz_neb_${MODEL}_${EXP}_${DATA}_lonlat_seamask.nc eca_txx_amz_neb_${MODEL}_${EXP}_${DATA}_yr_${DATA}_lonlat.nc

echo 
echo "2. Calculate txn"
cdo -yearmin tasmax_amz_neb_${MODEL}_${EXP}_${DATA}_lonlat_seamask.nc eca_txn_amz_neb_${MODEL}_${EXP}_${DATA}_yr_${DATA}_lonlat.nc

echo 
echo "3. Calculate tnx"
cdo -yearmax tasmin_amz_neb_${MODEL}_${EXP}_${DATA}_lonlat_seamask.nc eca_tnx_amz_neb_${MODEL}_${EXP}_${DATA}_yr_${DATA}_lonlat.nc

echo 
echo "4. Calculate tnn"
cdo -yearmin tasmin_amz_neb_${MODEL}_${EXP}_${DATA}_lonlat_seamask.nc eca_tnn_amz_neb_${MODEL}_${EXP}_${DATA}_yr_${DATA}_lonlat.nc

echo 
echo "5. Calculate dtr"
cdo yearmean -sub tasmax_amz_neb_${MODEL}_${EXP}_${DATA}_lonlat_seamask.nc tasmin_amz_neb_${MODEL}_${EXP}_${DATA}_lonlat_seamask.nc eca_dtr_amz_neb_${MODEL}_${EXP}_yr_${DATA}_lonlat.nc

echo
echo "6. Calculate 90th and 10th percentile - tmax"
cdo timmin tasmax_amz_neb_${MODEL}_${EXP}_${DATA}_lonlat_seamask.nc tasmax_minfile.nc
cdo timmax tasmax_amz_neb_${MODEL}_${EXP}_${DATA}_lonlat_seamask.nc tasmax_maxfile.nc
cdo timpctl,90 tasmax_amz_neb_${MODEL}_${EXP}_${DATA}_lonlat_seamask.nc tasmax_minfile.nc tasmax_maxfile.nc tasmax_90th_percentile_${DATA}.nc 
cdo timpctl,10 tasmax_amz_neb_${MODEL}_${EXP}_${DATA}_lonlat_seamask.nc tasmax_minfile.nc tasmax_maxfile.nc tasmax_10th_percentile_${DATA}.nc 

echo
echo "7. Calculate 90th and 10th percentile - tmin"
cdo timmin tasmin_amz_neb_${MODEL}_${EXP}_${DATA}_lonlat_seamask.nc tasmin_minfile.nc
cdo timmax tasmin_amz_neb_${MODEL}_${EXP}_${DATA}_lonlat_seamask.nc tasmin_maxfile.nc
cdo timpctl,90 tasmin_amz_neb_${MODEL}_${EXP}_${DATA}_lonlat_seamask.nc tasmin_minfile.nc tasmin_maxfile.nc tasmin_90th_percentile_${DATA}.nc 
cdo timpctl,10 tasmin_amz_neb_${MODEL}_${EXP}_${DATA}_lonlat_seamask.nc tasmin_minfile.nc tasmin_maxfile.nc tasmin_10th_percentile_${DATA}.nc 

for YEAR in `seq -w 1986 2005`; do

	echo
	echo ${YEAR}
	echo 

	echo "8. Select year"
	cdo seldate,${YEAR}-01-01,${YEAR}-12-31 tasmax_amz_neb_${MODEL}_${EXP}_${DATA}_lonlat_seamask.nc tasmax_${YEAR}.nc
	cdo seldate,${YEAR}-01-01,${YEAR}-12-31 tasmin_amz_neb_${MODEL}_${EXP}_${DATA}_lonlat_seamask.nc tasmin_${YEAR}.nc

	cdo addc,273.15 tasmax_${YEAR}.nc tasmax_K_${YEAR}.nc
	cdo addc,273.15 tasmin_${YEAR}.nc tasmin_K_${YEAR}.nc

	echo 
	echo "9. Calculate su"
	cdo eca_su tasmax_K_${YEAR}.nc su_K_${YEAR}.nc

	echo 
	echo "10. Calculate tr"
	cdo eca_tr tasmin_K_${YEAR}.nc tr_K_${YEAR}.nc

	echo 
	echo "9. Calculate tx90p"
	ntime=`cdo ntime tasmax_${YEAR}.nc`
    	cdo duplicate,${ntime} tasmax_90th_percentile_${DATA}.nc tasmax_90th_percentile_${DATA}_ntime.nc 
	cdo eca_tx90p tasmax_${YEAR}.nc tasmax_90th_percentile_${DATA}_ntime.nc tx90p_${YEAR}.nc

	echo 
	echo "11. Calculate tx10p"
    	cdo duplicate,${ntime} tasmax_10th_percentile_${DATA}.nc tasmax_10th_percentile_${DATA}_ntime.nc 
	cdo eca_tx10p tasmax_${YEAR}.nc tasmax_10th_percentile_${DATA}_ntime.nc tx10p_${YEAR}.nc

	echo 
	echo "10. Calculate tn90p"
	ntime=`cdo ntime tasmin_${YEAR}.nc`
    	cdo duplicate,${ntime} tasmin_90th_percentile_${DATA}.nc tasmin_90th_percentile_${DATA}_ntime.nc 
	cdo eca_tn90p tasmin_${YEAR}.nc tasmin_90th_percentile_${DATA}_ntime.nc tn90p_${YEAR}.nc

	echo 
	echo "12. Calculate tn10p"
    	cdo duplicate,${ntime} tasmin_10th_percentile_${DATA}.nc tasmin_10th_percentile_${DATA}_ntime.nc 
	cdo eca_tn10p tasmin_${YEAR}.nc tasmin_10th_percentile_${DATA}_ntime.nc tn10p_${YEAR}.nc

done

echo 
echo "11. Concatenate data"
cdo cat su_*.nc eca_su_amz_neb_${MODEL}_${EXP}_yr_${DATA}_lonlat.nc
cdo cat tr_*.nc eca_tr_amz_neb_${MODEL}_${EXP}_yr_${DATA}_lonlat.nc
cdo cat tx90p_*.nc eca_tx90p_amz_neb_${MODEL}_${EXP}_yr_${DATA}_lonlat.nc
cdo cat tx10p_*.nc eca_tx10p_amz_neb_${MODEL}_${EXP}_yr_${DATA}_lonlat.nc
cdo cat tn90p_*.nc eca_tn90p_amz_neb_${MODEL}_${EXP}_yr_${DATA}_lonlat.nc
cdo cat tn10p_*.nc eca_tn10p_amz_neb_${MODEL}_${EXP}_yr_${DATA}_lonlat.nc

echo 
echo "12. Delete files"
rm su_K*
rm tr_K*
rm tasmax_K*
rm tasmin_K*
rm tasmin_1*
rm tasmin_2*
rm tasmax_1*
rm tasmax_2*
rm tasmax_9*
rm tasmin_9*
rm tx90p_1*
rm tx90p_2*
rm tx10p_1*
rm tx10p_2*
rm tn90p_1*
rm tn90p_2*
rm tn10p_1*
rm tn10p_2*
rm *minfile*
rm *maxfile*

echo
echo "--------------- END CALCULATE INDEX REGCM AND HADGEM OUTPUT ----------------"


