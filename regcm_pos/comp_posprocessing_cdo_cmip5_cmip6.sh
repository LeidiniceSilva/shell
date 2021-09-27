#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '09/26/2021'
#__description__ = 'Posprocessing from CMIP5 and CMI6 models'

#~ echo
#~ echo "--------------- INIT POSPROCESSING CMIP5 MODELS ----------------"

#~ var="pr"
#~ exp="historical_r1i1p1"
#~ dir=/home/nice/Documents/dataset/gcm/cmip6/cmip5/

#~ echo "1. Select date"
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_BCC-CSM1.1_${exp}_185001-201212.nc     ${var}_Amon_BCC-CSM1.1_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_BCC-CSM1.1M_${exp}_185001-201212.nc    ${var}_Amon_BCC-CSM1.1M_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_BNU-ESM_${exp}_185001-200512.nc        ${var}_Amon_BNU-ESM_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_CanESM2_${exp}_185001-200512.nc        ${var}_Amon_CanESM2_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_CCSM4_${exp}_185001-200512.nc          ${var}_Amon_CCSM4_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_CESM1-BGC_${exp}_185001-200512.nc      ${var}_Amon_CESM1-BGC_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_CESM1-CAM5_${exp}_185001-200512.nc     ${var}_Amon_CESM1-CAM5_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_CESM1-FASTCHEM_${exp}_185001-200512.nc ${var}_Amon_CESM1-FASTCHEM_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_CESM1-WACCM_${exp}_185001-200512.nc    ${var}_Amon_CESM1-WACCM_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_CMCC-CMS_${exp}_1960001-200512.nc       ${var}_Amon_CMCC-CMS_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_CNRM-CM5_${exp}_195001-200512.nc       ${var}_Amon_CNRM-CM5_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_CSIRO-ACCESS-1_${exp}_185001-200512.nc ${var}_Amon_CSIRO-ACCESS-1_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_CSIRO-ACCESS-3_${exp}_185001-200512.nc ${var}_Amon_CSIRO-ACCESS-3_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_FGOALS-g2_${exp}_190001-201412.nc      ${var}_Amon_FGOALS-g2_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_FGOALS-s2_${exp}_185001-200512.nc      ${var}_Amon_FGOALS-s2_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_FIO-ESM_${exp}_185001-200512.nc      ${var}_Amon_FIO-ESM_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_GFDL-ESM2G_${exp}_186101-200512.nc   ${var}_Amon_GFDL-ESM2G_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_GFDL-ESM2M_${exp}_186101-200512.nc   ${var}_Amon_GFDL-ESM2M_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_GISS-E2-H-CC_${exp}_195101-201012.nc ${var}_Amon_GISS-E2-H-CC_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_GISS-E2-H_${exp}_185001-200512.nc    ${var}_Amon_GISS-E2-H_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_GISS-E2-R-CC_${exp}_185001-201012.nc ${var}_Amon_GISS-E2-R-CC_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_GISS-E2-R_${exp}_185001-200512.nc    ${var}_Amon_GISS-E2-R_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-11-30T00:00:00 ${var}_Amon_HadGEM2-ES_${exp}_185912-200511.nc   ${var}_Amon_HadGEM2-ES_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_inmcm4_${exp}_185001-200512.nc       ${var}_Amon_INMCM4_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_IPSL-CM5A-LR_${exp}_185001-200512.nc ${var}_Amon_IPSL-CM5A-LR_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_IPSL-CM5A-MR_${exp}_185001-200512.nc ${var}_Amon_IPSL-CM5A-MR_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_MIROC5_${exp}_185001-201212.nc       ${var}_Amon_MIROC5_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_MIROC-ESM_${exp}_185001-200512.nc    ${var}_Amon_MIROC-ESM_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_MPI-ESM-LR_${exp}_185001-200512.nc   ${var}_Amon_MPI-ESM-LR_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_MPI-ESM-MR_${exp}_185001-200512.nc   ${var}_Amon_MPI-ESM-MR_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_MRI-CGCM3_${exp}_185001-200512.nc    ${var}_Amon_MRI-CGCM3_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_NorESM1-ME_${exp}_185001-200512.nc   ${var}_Amon_NorESM1-ME_${exp}_1961-2005_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2005-12-31T00:00:00 ${var}_Amon_NorESM1-M_${exp}_185001-200512.nc    ${var}_Amon_NorESM1-M_${exp}_1961-2005_seldate.nc 

#~ model_list=( 'BCC-CSM1.1' 'BCC-CSM1.1M' 'BNU-ESM' 'CanESM2' 'CCSM4' 'CESM1-BGC' 'CESM1-CAM5' 'CESM1-FASTCHEM' 'CESM1-WACCM' 'CMCC-CMS' 'CNRM-CM5' 'CSIRO-ACCESS-1' 'CSIRO-ACCESS-3' 'FGOALS-g2' 'FGOALS-s2' 'FIO-ESM' 'GISS-E2-H-CC' 'GISS-E2-H' 'GISS-E2-R-CC' 'GISS-E2-R' 'HadGEM2-ES' 'INMCM4' 'IPSL-CM5A-LR' 'IPSL-CM5A-MR' 'MIROC5' 'MIROC-ESM' 'MPI-ESM-LR' 'MPI-ESM-MR' 'MRI-CGCM3' 'NorESM1-ME' 'NorESM1-M' )    

#~ for model in ${model_list[@]}; do

	#~ echo
	#~ echo "Model: " ${model}
	
	#~ echo
	#~ echo "2. Convert calendar"
	#~ cdo setcalendar,standard ${var}_Amon_${model}_${exp}_1961-2005_seldate.nc ${var}_Amon_${model}_${exp}_1961-2005_calendar.nc

	#~ echo
	#~ echo "3. Convert unit"
	#~ cdo mulc,86400 ${var}_Amon_${model}_${exp}_1961-2005_calendar.nc ${var}_SA_Amon_${model}_${exp}_1961-2005.nc

	#~ echo
	#~ echo "4. Remapbil"
	#~ /home/nice/Documents/github_projects/shell/regcm_pos/./regrid ${var}_SA_Amon_${model}_${exp}_1961-2005.nc -60,15,0.5 -90,-30,0.5 bil

	#~ echo
	#~ echo "5. Creating sea mask"
	#~ cdo -f nc -remapnn,${var}_SA_Amon_${model}_${exp}_1961-2005_lonlat.nc -gtc,0 -topo ${var}_${model}_seamask.nc
	#~ cdo ifthen ${var}_${model}_seamask.nc ${var}_SA_Amon_${model}_${exp}_1961-2005_lonlat.nc ${var}_SA_Amon_${model}_${exp}_1961-2005_lonlat_mask.nc

	#~ echo
	#~ echo "6. Calculate annual climatlogy"
	#~ cdo -yearavg ${dir}${var}_SA_Amon_${model}_${exp}_1961-2005_lonlat_mask.nc ${dir}${var}_SA_Ayr_${model}_${exp}_1961-2005_lonlat_mask.nc

	#~ echo
	#~ echo "7. Select subdomain"
	#~ cdo sellonlatbox,-68,-52,-12,-3  ${dir}${var}_SA_Amon_${model}_${exp}_1961-2005_lonlat_mask.nc ${dir}${var}_SAMZ_Amon_${model}_${exp}_1961-2005_lonlat_mask.nc
	#~ cdo sellonlatbox,-61,-48,-37,-27 ${dir}${var}_SA_Amon_${model}_${exp}_1961-2005_lonlat_mask.nc ${dir}${var}_SLPB_Amon_${model}_${exp}_1961-2005_lonlat_mask.nc
	#~ cdo sellonlatbox,-47,-35,-15,-2  ${dir}${var}_SA_Amon_${model}_${exp}_1961-2005_lonlat_mask.nc ${dir}${var}_ENEB_Amon_${model}_${exp}_1961-2005_lonlat_mask.nc

#~ done

#~ echo
#~ echo "--------------- INIT POSPROCESSING CMIP6 MODELS ----------------"

#~ var="pr"
#~ exp="historical_r1i1p1f1"
#~ dir=/home/nice/Documents/dataset/gcm/cmip6/cmip6/

#~ echo "1. Select date"
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_ACCESS-ESM1-5_${exp}_gn_185001-201412.nc  ${var}_Amon_ACCESS-ESM1-5_${exp}_gn_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_BCC-CSM2-MR_${exp}_gn_185001-201412.nc    ${var}_Amon_BCC-CSM2-MR_${exp}_gn_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_BCC-ESM1_${exp}_gn_185001-201412.nc       ${var}_Amon_BCC-ESM1_${exp}_gn_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_CAMS-CSM1-0_${exp}_gn_185001-201412.nc    ${var}_Amon_CAMS-CSM1-0_${exp}_gn_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_CanESM5_${exp}_gn_185001-201412.nc        ${var}_Amon_CanESM5_${exp}_gn_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_CESM2-WACCM_${exp}_gn_185001-201412.nc    ${var}_Amon_CESM2-WACCM_${exp}_gn_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_CMCC-ESM2_${exp}_gn_185001-201412.nc      ${var}_Amon_CMCC-ESM2_${exp}_gn_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_FGOALS-g3_${exp}_gn_196001-201612.nc      ${var}_Amon_FGOALS-g3_${exp}_gn_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_FIO-ESM-2-0_${exp}_gn_185001-201412.nc    ${var}_Amon_FIO-ESM-2-0_${exp}_gn_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_GFDL-ESM4_${exp}_gr1_195001-201412.nc     ${var}_Amon_GFDL-ESM4_${exp}_gr1_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_GISS-E2-1-G-CC_${exp}_gn_195101-201412.nc ${var}_Amon_GISS-E2-1-G-CC_${exp}_gn_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_GISS-E2-1-G_${exp}_gn_195101-201412.nc    ${var}_Amon_GISS-E2-1-G_${exp}_gn_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_INM-CM5-0_${exp}_gr1_195001-201412.nc     ${var}_Amon_INM-CM5-0_${exp}_gr1_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_IPSL-CM6A-LR_${exp}_gr_185001-201412.nc   ${var}_Amon_IPSL-CM6A-LR_${exp}_gr_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_MCM-UA-1-0_${exp}_gn_185001-201412.nc     ${var}_Amon_MCM-UA-1-0_${exp}_gn_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_MIROC6_${exp}_gn_195001-201412.nc         ${var}_Amon_MIROC6_${exp}_gn_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_MPI-ESM1-2-HR_${exp}_gn_196001-201412.nc  ${var}_Amon_MPI-ESM1-2-HR_${exp}_gn_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_MRI-ESM2-0_${exp}_gn_185001-201412.nc     ${var}_Amon_MRI-ESM2-0_${exp}_gn_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_NESM3_${exp}_gn_185001-201412.nc          ${var}_Amon_NESM3_${exp}_gn_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_NorCPM1_${exp}_gn_185001-201412.nc        ${var}_Amon_NorCPM1_${exp}_gn_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_NorESM2-MM_${exp}_gn_196001-201412.nc     ${var}_Amon_NorESM2-MM_${exp}_gn_1961-2014_seldate.nc 
#~ cdo seldate,1961-01-01T00:00:00,2014-12-31T00:00:00 ${var}_Amon_SAM0-UNICON_${exp}_gn_196001-201412.nc    ${var}_Amon_SAM0-UNICON_${exp}_gn_1961-2014_seldate.nc 
 
#~ model_list=( 'ACCESS-ESM1-5' 'BCC-CSM2-MR' 'BCC-ESM1' 'CAMS-CSM1-0' 'CanESM5' 'CESM2-WACCM' 'CMCC-ESM2' 'FGOALS-g3' 'FIO-ESM-2-0' 'GFDL-ESM4' 'GISS-E2-1-G-CC' 'GISS-E2-1-G' 'INM-CM5-0' 'IPSL-CM6A-LR' 'MCM-UA-1-0' 'MIROC6' 'MPI-ESM1-2-HR' 'MRI-ESM2-0' 'NESM3' 'NorCPM1' 'NorESM2-MM' 'SAM0-UNICON')    

#~ for model in ${model_list[@]}; do

	#~ echo
	#~ echo "Model: " ${model}
	
	#~ echo
	#~ echo "2. Convert calendar"
	#~ cdo setcalendar,standard ${var}_Amon_${model}_${exp}_gr_1961-2014_seldate.nc ${var}_Amon_${model}_${exp}_gr_1961-2014_calendar.nc

	#~ echo
	#~ echo "3. Convert unit"
	#~ cdo mulc,86400 ${var}_Amon_${model}_${exp}_gr_1961-2014_calendar.nc ${var}_SA_Amon_${model}_${exp}_gr_1961-2014.nc

	#~ echo
	#~ echo "4. Remapbil"
	#~ /home/nice/Documents/github_projects/shell/regcm_pos/./regrid ${var}_SA_Amon_${model}_${exp}_gr_1961-2014.nc -60,15,0.5 -90,-30,0.5 bil

	#~ echo
	#~ echo "5. Creating sea mask"
	#~ cdo -f nc -remapnn,${var}_SA_Amon_${model}_${exp}_gr_1961-2014_lonlat.nc -gtc,0 -topo ${var}_${model}_seamask.nc
	#~ cdo ifthen ${var}_${model}_seamask.nc ${var}_SA_Amon_${model}_${exp}_gr_1961-2014_lonlat.nc ${var}_SA_Amon_${model}_${exp}_gr_1961-2014_lonlat_mask.nc
	
	#~ echo
	#~ echo "6. Calculate annual climatlogy"
	#~ cdo -yearavg ${dir}${var}_SA_Amon_${model}_${exp}_gr_1961-2014_lonlat_mask.nc ${dir}${var}_SA_Ayr_${model}_${exp}_gr_1961-2014_lonlat_mask.nc

	#~ echo
	#~ echo "7. Select subdomain"
	#~ cdo sellonlatbox,-68,-52,-12,-3  ${dir}${var}_SA_Amon_${model}_${exp}_gr_1961-2014_lonlat_mask.nc ${dir}${var}_SAMZ_Amon_${model}_${exp}_gr_1961-2014_lonlat_mask.nc
	#~ cdo sellonlatbox,-61,-48,-37,-27 ${dir}${var}_SA_Amon_${model}_${exp}_gr_1961-2014_lonlat_mask.nc ${dir}${var}_SLPB_Amon_${model}_${exp}_gr_1961-2014_lonlat_mask.nc
	#~ cdo sellonlatbox,-47,-35,-15,-2  ${dir}${var}_SA_Amon_${model}_${exp}_gr_1961-2014_lonlat_mask.nc ${dir}${var}_NEB_Amon_${model}_${exp}_gr_1961-2014_lonlat_mask.nc

#~ done

#~ echo
#~ echo "--------------- THE END POSPROCESSING MODEL ----------------"
