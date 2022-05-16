#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '01/01/2021'
#__description__ = 'Calculate extreme index with ECA_CDO'

echo
echo "--------------- INIT CALCULATE EXTREME INDICES ETCCDI ----------------"

DATA="1986-2005"
DIR="/home/nice/Documents/dataset/obs/eca"

echo
cd ${DIR}
echo ${DIR}

for YEAR in `seq -w 1986 2005`; do

	echo ${YEAR}
	echo "1. Select year"
	cdo seldate,${YEAR}-01-01,${YEAR}-12-31 precip_cpc_obs_day_${DATA}.nc prec_${YEAR}.nc

	echo 
	echo "2. Calculate prcptot"
	cdo monsum prec_${YEAR}.nc prec_mon_${YEAR}.nc
	cdo yearsum prec_mon_${YEAR}.nc prcptot_${YEAR}.nc

	echo 
	echo "3. Calculate r95ptot"
	cdo timsum prec_${YEAR}.nc timsum_${YEAR}.nc 
	cdo -L timpctl,95 prec_${YEAR}.nc -timmin prec_${YEAR}.nc -timmax prec_${YEAR}.nc q95_${YEAR}.nc 
	cdo -L -timsum -mul -ge prec_${YEAR}.nc q95_${YEAR}.nc prec_${YEAR}.nc total_ge_q95_${YEAR}.nc 
	cdo -L mulc,100 -div total_ge_q95_${YEAR}.nc timsum_${YEAR}.nc r95p_${YEAR}.nc

	echo 
	echo "4. Calculate r99ptot"
	cdo -L timpctl,99 prec_${YEAR}.nc -timmin prec_${YEAR}.nc -timmax prec_${YEAR}.nc q99_${YEAR}.nc 
	cdo -L -timsum -mul -ge prec_${YEAR}.nc q99_${YEAR}.nc prec_${YEAR}.nc total_ge_q99_${YEAR}.nc 
	cdo -L mulc,100 -div total_ge_q99_${YEAR}.nc timsum_${YEAR}.nc r99p_${YEAR}.nc

	echo 
	echo "5. Calculate rx1day"
	cdo -s eca_rx1day,m prec_${YEAR}.nc rx1_mon_${YEAR}.nc
	cdo yearmean rx1_mon_${YEAR}.nc rx1day_${YEAR}.nc

	echo 
	echo "6. Calculate rx5day"
	cdo -s eca_rx5day,50 prec_${YEAR}.nc rx5day_${YEAR}.nc

	echo 
	echo "7. Calculate sdii"
	cdo eca_sdii prec_${YEAR}.nc sdii_${YEAR}.nc

	echo 
	echo "8. Calculate cdd"
	cdo eca_cdd prec_${YEAR}.nc cdd_${YEAR}.nc

	echo 
	echo "9. Calculate cwd"
	cdo eca_cwd prec_${YEAR}.nc cwd_${YEAR}.nc

	echo 
	echo "10. Calculate r10mm"
	cdo eca_r10mm prec_${YEAR}.nc r10mm_${YEAR}.nc

	echo 
	echo "11. Calculate r20mm"
	cdo eca_r20mm prec_${YEAR}.nc r20mm_${YEAR}.nc

done

echo 
echo "12. Concatenate data"
cdo cat prcptot_*.nc eca_prcptot_amz_neb_cpc_obs_yr_${DATA}.nc
cdo cat r95p_*.nc eca_r95p_amz_neb_cpc_obs_yr_${DATA}.nc
cdo cat r99p_*.nc eca_r99p_amz_neb_cpc_obs_yr_${DATA}.nc
cdo cat rx1day_*.nc eca_rx1day_amz_neb_cpc_obs_yr_${DATA}.nc
cdo cat rx5day_*.nc eca_rx5day_amz_neb_cpc_obs_yr_${DATA}.nc
cdo cat sdii_*.nc eca_sdii_amz_neb_cpc_obs_yr_${DATA}.nc
cdo cat cdd_*.nc eca_cdd_amz_neb_cpc_obs_yr_${DATA}.nc
cdo cat cwd_*.nc eca_cwd_amz_neb_cpc_obs_yr_${DATA}.nc
cdo cat r10mm_*.nc eca_r10mm_amz_neb_cpc_obs_yr_${DATA}.nc
cdo cat r20mm_*.nc eca_r20mm_amz_neb_cpc_obs_yr_${DATA}.nc

echo 
echo "13. Regular grid"
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_prcptot_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_r95p_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_r99p_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_rx1day_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_rx5day_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_sdii_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_cdd_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_cwd_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_r10mm_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid eca_r20mm_amz_neb_cpc_obs_yr_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil

echo 
echo "14. Delete files"
rm prcptot*
rm prec_1*.nc
rm prec_2*.nc
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
rm *amz_neb_cpc_obs_yr_${DATA}.nc

echo
echo "--------------- THE END CALCULATE EXTREME INDICES ETCCDI ----------------"


