#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '01/18/2021'
#__description__ = 'Calculate extreme index with ECA_CDO'

echo
echo "--------------- INIT CALCULATE INDEX XAVIER BATASET ----------------"

DATA="1986-2005"
DIR="/home/nice/Documents/dataset/obs/eca"

echo
cd ${DIR}
echo ${DIR}

for YEAR in `seq -w 1986 2005`; do

	echo ${YEAR}
	echo "1. Select year"
	cdo seldate,${YEAR}-01-01,${YEAR}-12-31 tmax_daily_UT_Brazil_v2.2_${DATA}.nc tmax_${YEAR}.nc
	cdo seldate,${YEAR}-01-01,${YEAR}-12-31 tmin_daily_UT_Brazil_v2.2_${DATA}.nc tmin_${YEAR}.nc

	echo 
	echo "2. Calculate txx"
	cdo subc,273.15 -yearmax tmax_${YEAR}.nc txx_${YEAR}.nc

	echo 
	echo "3. Calculate txn"
	cdo subc,273.15 -yearmin tmax_${YEAR}.nc txn_${YEAR}.nc

	echo 
	echo "4. Calculate tnx"
	cdo subc,273.15 -yearmax tmim_${YEAR}.nc tnx_${YEAR}.nc

	echo 
	echo "5. Calculate tnn"
	cdo subc,273.15 -yearmin tmim_${YEAR}.nc tnn_${YEAR}.nc

	echo 
	echo "6. Calculate su"
	cdo eca_csu tmax_${YEAR}.nc su_${YEAR}.nc

	echo 
	echo "7. Calculate tr"
	cdo eca_tr tmim_${YEAR}.nc tr_${YEAR}.nc

	echo 
	echo "8. Calculate dtr"
	cdo yearmean -sub tmax_${YEAR}.nc tmin_${YEAR}.nc dtr_${YEAR}.nc

	echo 
	echo "9. Calculate tx90p"
	cdo -L timpctl,90 tmax_${YEAR}.nc -timmin tmax_${YEAR}.nc -timmax tmax_${YEAR}.nc q90_tmax_${YEAR}.nc
	cdo eca_tx90p tmax_${YEAR}.nc q90_tmax_${YEAR}.nc tx90p_${YEAR}.nc

	echo 
	echo "10. Calculate tn90p"
	cdo -L timpctl,90 tmin_${YEAR}.nc -timmin tmin_${YEAR}.nc -timmax tmin_${YEAR}.nc q90_tmin_${YEAR}.nc
	cdo eca_tn90p tmin_${YEAR}.nc q90_tmin_${YEAR}.nc tn90p_${YEAR}.nc

	echo 
	echo "9. Calculate tx10p"
	cdo -L timpctl,10 tmax_${YEAR}.nc -timmin tmax_${YEAR}.nc -timmax tmax_${YEAR}.nc q10_tmax_${YEAR}.nc
	cdo eca_tx10p tmax_${YEAR}.nc q10_tmax_${YEAR}.nc tx10p_${YEAR}.nc

	echo 
	echo "10. Calculate tn10p"
	cdo -L timpctl,10 tmin_${YEAR}.nc -timmin tmin_${YEAR}.nc -timmax tmin_${YEAR}.nc q10_tmin_${YEAR}.nc
	cdo eca_tn10p tmin_${YEAR}.nc q10_tmin_${YEAR}.nc tn10p_${YEAR}.nc
done

echo 
echo "12. Concatenate data"
cdo cat txx_*.nc eca_txx_amz_neb_xavier_obs_yr_${DATA}.nc
cdo cat txn_*.nc eca_txn_amz_neb_xavier_obs_yr_${DATA}.nc
cdo cat tnx_*.nc eca_tnx_amz_neb_xavier_obs_yr_${DATA}.nc
cdo cat tnn_*.nc eca_tnn_amz_neb_xavier_obs_yr_${DATA}.nc
cdo cat su_*.nc eca_su_amz_neb_xavier_obs_yr_${DATA}.nc
cdo cat tr_*.nc eca_tr_amz_neb_xavier_obs_yr_${DATA}.nc
cdo cat dtr_*.nc eca_dtr_amz_neb_xavier_obs_yr_${DATA}.nc
cdo cat tx90p_*.nc eca_tx90p_amz_neb_xavier_obs_yr_${DATA}.nc
cdo cat tn90p_*.nc eca_tn90p_amz_neb_xavier_obs_yr_${DATA}.nc
cdo cat tx10p_*.nc eca_tx10p_amz_neb_xavier_obs_yr_${DATA}.nc
cdo cat tn10p_*.nc eca_tn10p_amz_neb_xavier_obs_yr_${DATA}.nc

echo 
echo "13. Regular grid"
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_txt_amz_neb_xavier_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_txn_amz_neb_xavier_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_tnx_amz_neb_xavier_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_tnn_amz_neb_xavier_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_su_amz_neb_xavier_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_tr_amz_neb_xavier_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_dtr_amz_neb_xavier_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_tx90p_amz_neb_xavier_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_tn90p_amz_neb_xavier_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_tx10p_amz_neb_xavier_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_tn10p_amz_neb_xavier_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil

echo 
echo "14. Delete files"
rm txx*
rm txn*
rm tnx*
rm tnn*
rm su*
rm tr*
rm dtr*
rm tx90p*
rm tn90p*
rm tx10p*
rm tn10p*
rm q90*
rm *amz_neb_xavier_obs_yr_${DATA}.nc

echo
echo "--------------- THE END CALCULATE INDEX XAVIER BATASET ----------------"


