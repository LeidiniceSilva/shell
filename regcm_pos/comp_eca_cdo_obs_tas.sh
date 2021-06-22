#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '01/01/2021'
#__description__ = 'Calculate extreme index with ECA_CDO'

echo
echo "--------------- INIT CALCULATE INDEX XAVIER DATASET ----------------"

DATA="1986-2005"
DIR="/home/nice/Documents/dataset/obs/eca"

echo
cd ${DIR}
echo ${DIR}

echo 
echo "1. Calculate txx"
cdo -yearmax tmax_cpc_obs_day_${DATA}.nc eca_txx_amz_neb_cpc_obs_yr_${DATA}.nc

echo 
echo "2. Calculate txn"
cdo -yearmin tmax_cpc_obs_day_${DATA}.nc eca_txn_amz_neb_cpc_obs_yr_${DATA}.nc

echo 
echo "3. Calculate tnx"
cdo -yearmax tmin_cpc_obs_day_${DATA}.nc eca_tnx_amz_neb_cpc_obs_yr_${DATA}.nc

echo 
echo "4. Calculate tnn"
cdo -yearmin tmin_cpc_obs_day_${DATA}.nc eca_tnn_amz_neb_cpc_obs_yr_${DATA}.nc

echo 
echo "5. Calculate dtr"
cdo yearmean -sub tmax_cpc_obs_day_${DATA}.nc tmin_cpc_obs_day_${DATA}.nc eca_dtr_amz_neb_cpc_obs_yr_${DATA}.nc

echo
echo "6. Calculate 90th and 10th percentile - tmax"
cdo timmin tmax_cpc_obs_day_${DATA}.nc tmax_minfile.nc
cdo timmax tmax_cpc_obs_day_${DATA}.nc tmax_maxfile.nc
cdo timpctl,90 tmax_cpc_obs_day_${DATA}.nc tmax_minfile.nc tmax_maxfile.nc tmax_90th_percentile_${DATA}.nc 
cdo timpctl,10 tmax_cpc_obs_day_${DATA}.nc tmax_minfile.nc tmax_maxfile.nc tmax_10th_percentile_${DATA}.nc 

echo
echo "7. Calculate 90th and 10th percentile - tmin"
cdo timmin tmin_cpc_obs_day_${DATA}.nc tmin_minfile.nc
cdo timmax tmin_cpc_obs_day_${DATA}.nc tmin_maxfile.nc
cdo timpctl,90 tmin_cpc_obs_day_${DATA}.nc tmin_minfile.nc tmin_maxfile.nc tmin_90th_percentile_${DATA}.nc 
cdo timpctl,10 tmin_cpc_obs_day_${DATA}.nc tmin_minfile.nc tmin_maxfile.nc tmin_10th_percentile_${DATA}.nc 

for YEAR in `seq -w 1986 2005`; do

	echo
	echo ${YEAR}
	echo 

	echo "8. Select year"
	cdo seldate,${YEAR}-01-01,${YEAR}-12-31 tmax_cpc_obs_day_${DATA}.nc tmax_${YEAR}.nc
	cdo seldate,${YEAR}-01-01,${YEAR}-12-31 tmin_cpc_obs_day_${DATA}.nc tmin_${YEAR}.nc

	cdo addc,273.15 tmax_${YEAR}.nc tmax_K_${YEAR}.nc
	cdo addc,273.15 tmin_${YEAR}.nc tmin_K_${YEAR}.nc

	echo 
	echo "9. Calculate su"
	cdo eca_su tmax_K_${YEAR}.nc su_K_${YEAR}.nc

	echo 
	echo "10. Calculate tr"
	cdo eca_tr tmin_K_${YEAR}.nc tr_K_${YEAR}.nc

	echo 
	echo "9. Calculate tx90p"
	ntime=`cdo ntime tmax_${YEAR}.nc`
    	cdo duplicate,${ntime} tmax_90th_percentile_${DATA}.nc tmax_90th_percentile_${DATA}_ntime.nc 
	cdo eca_tx90p tmax_${YEAR}.nc tmax_90th_percentile_${DATA}_ntime.nc tx90p_${YEAR}.nc

	echo 
	echo "11. Calculate tx10p"
    	cdo duplicate,${ntime} tmax_10th_percentile_${DATA}.nc tmax_10th_percentile_${DATA}_ntime.nc 
	cdo eca_tx10p tmax_${YEAR}.nc tmax_10th_percentile_${DATA}_ntime.nc tx10p_${YEAR}.nc

	echo 
	echo "10. Calculate tn90p"
	ntime=`cdo ntime tmin_${YEAR}.nc`
    	cdo duplicate,${ntime} tmin_90th_percentile_${DATA}.nc tmin_90th_percentile_${DATA}_ntime.nc 
	cdo eca_tn90p tmin_${YEAR}.nc tmin_90th_percentile_${DATA}_ntime.nc tn90p_${YEAR}.nc

	echo 
	echo "12. Calculate tn10p"
    	cdo duplicate,${ntime} tmin_10th_percentile_${DATA}.nc tmin_10th_percentile_${DATA}_ntime.nc 
	cdo eca_tn10p tmin_${YEAR}.nc tmin_10th_percentile_${DATA}_ntime.nc tn10p_${YEAR}.nc

done

echo 
echo "11. Concatenate data"
cdo cat su_*.nc eca_su_amz_neb_cpc_obs_yr_${DATA}.nc
cdo cat tr_*.nc eca_tr_amz_neb_cpc_obs_yr_${DATA}.nc
cdo cat tx90p_*.nc eca_tx90p_amz_neb_cpc_obs_yr_${DATA}.nc
cdo cat tx10p_*.nc eca_tx10p_amz_neb_cpc_obs_yr_${DATA}.nc
cdo cat tn90p_*.nc eca_tn90p_amz_neb_cpc_obs_yr_${DATA}.nc
cdo cat tn10p_*.nc eca_tn10p_amz_neb_cpc_obs_yr_${DATA}.nc

echo 
echo "13. Regular grid"
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_txx_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_txn_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_tnx_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_tnn_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_dtr_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_su_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_tr_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_tx90p_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_tx10p_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_tn90p_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_tn10p_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil

echo 
echo "14. Delete files"
rm tmax_K*
rm tmin_K*
rm tmin_1*
rm tmin_2*
rm tmax_1*
rm tmax_2*
rm tmax_9*
rm tmin_9*
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
rm *amz_neb_cpc_obs_yr_${DATA}.nc

echo
echo "--------------- THE END CALCULATE INDEX XAVIER DATASET ----------------"


