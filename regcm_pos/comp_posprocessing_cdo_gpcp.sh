#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '01/24/2023'
#__description__ = 'Posprocessing dataset'

var="tcc"

cdo -r -timselavg,3 -selmon,1,2,12 ${var}_amz_neb_era5_mon_2001-2005.nc ${var}_amz_neb_era5_djf_2001-2005.nc
cdo -r -timselavg,3 -selmon,6,7,8 ${var}_amz_neb_era5_mon_2001-2005.nc ${var}_amz_neb_era5_jja_2001-2005.nc
cdo -yearavg ${var}_amz_neb_era5_mon_2001-2005.nc ${var}_amz_neb_era5_ann_2001-2005.nc

cdo -r -timselavg,3 -selmon,1,2,12 ${var}_namz_era5_mon_2001-2005.nc ${var}_namz_era5_djf_2001-2005.nc
cdo -r -timselavg,3 -selmon,6,7,8 ${var}_namz_era5_mon_2001-2005.nc ${var}_namz_era5_jja_2001-2005.nc
cdo -yearavg ${var}_namz_era5_mon_2001-2005.nc ${var}_namz_era5_ann_2001-2005.nc

cdo -r -timselavg,3 -selmon,1,2,12 ${var}_samz_era5_mon_2001-2005.nc ${var}_samz_era5_djf_2001-2005.nc
cdo -r -timselavg,3 -selmon,6,7,8 ${var}_samz_era5_mon_2001-2005.nc ${var}_samz_era5_jja_2001-2005.nc
cdo -yearavg ${var}_samz_era5_mon_2001-2005.nc ${var}_samz_era5_ann_2001-2005.nc

cdo -r -timselavg,3 -selmon,1,2,12 ${var}_neb_era5_mon_2001-2005.nc ${var}_neb_era5_djf_2001-2005.nc
cdo -r -timselavg,3 -selmon,6,7,8 ${var}_neb_era5_mon_2001-2005.nc ${var}_neb_era5_jja_2001-2005.nc
cdo -yearavg ${var}_neb_era5_mon_2001-2005.nc ${var}_neb_era5_ann_2001-2005.nc

cdo -r -timselavg,3 -selmon,1,2,12 precip_amz_neb_gpcp_v2.3_obs_mon_2001-2005.nc precip_amz_neb_gpcp_v2.3_obs_djf_2001-2005.nc
cdo -r -timselavg,3 -selmon,6,7,8  precip_amz_neb_gpcp_v2.3_obs_mon_2001-2005.nc precip_amz_neb_gpcp_v2.3_obs_jja_2001-2005.nc
cdo -yearavg precip_amz_neb_gpcp_v2.3_obs_mon_2001-2005.nc precip_amz_neb_gpcp_v2.3_obs_ann_2001-2005.nc

cdo -r -timselavg,3 -selmon,1,2,12 precip_namz_gpcp_v2.3_obs_mon_2001-2005.nc precip_namz_gpcp_v2.3_obs_djf_2001-2005.nc
cdo -r -timselavg,3 -selmon,6,7,8  precip_namz_gpcp_v2.3_obs_mon_2001-2005.nc precip_namz_gpcp_v2.3_obs_jja_2001-2005.nc
cdo -yearavg precip_namz_gpcp_v2.3_obs_mon_2001-2005.nc precip_namz_gpcp_v2.3_obs_ann_2001-2005.nc

cdo -r -timselavg,3 -selmon,1,2,12 precip_samz_gpcp_v2.3_obs_mon_2001-2005.nc precip_samz_gpcp_v2.3_obs_djf_2001-2005.nc
cdo -r -timselavg,3 -selmon,6,7,8  precip_samz_gpcp_v2.3_obs_mon_2001-2005.nc precip_samz_gpcp_v2.3_obs_jja_2001-2005.nc
cdo -yearavg precip_samz_gpcp_v2.3_obs_mon_2001-2005.nc precip_samz_gpcp_v2.3_obs_ann_2001-2005.nc

cdo -r -timselavg,3 -selmon,1,2,12 precip_neb_gpcp_v2.3_obs_mon_2001-2005.nc precip_neb_gpcp_v2.3_obs_djf_2001-2005.nc
cdo -r -timselavg,3 -selmon,6,7,8  precip_neb_gpcp_v2.3_obs_mon_2001-2005.nc precip_neb_gpcp_v2.3_obs_jja_2001-2005.nc
cdo -yearavg precip_neb_gpcp_v2.3_obs_mon_2001-2005.nc precip_neb_gpcp_v2.3_obs_ann_2001-2005.nc

for YEAR in 2001 2002 2003 2004 2005; do
    for MON in 01 02 03 04 05 06 07 08 09 10 11 12; do
		for DAY in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31; do
    	    
			echo "1. Download file: CMORPH_V1.0_ADJ_0.25deg-DLY_00Z_${YEAR}${MON}${DAY}.nc"			
			/usr/bin/wget -N https://www.ncei.noaa.gov/data/cmorph-high-resolution-global-precipitation-estimates/access/daily/0.25deg/${YEAR}/${MON}/CMORPH_V1.0_ADJ_0.25deg-DLY_00Z_${YEAR}${MON}${DAY}.nc
						
        done
    done
done	

var="pr"
exp="exp2"

cdo -r -timselavg,3 -selmon,1,2,12 ${var}_amz_neb_regcm_${exp}_mon_2001-2005.nc ${var}_amz_neb_regcm_${exp}_djf_2001-2005.nc
cdo -r -timselavg,3 -selmon,6,7,8  ${var}_amz_neb_regcm_${exp}_mon_2001-2005.nc ${var}_amz_neb_regcm_${exp}_jja_2001-2005.nc
cdo -yearavg ${var}_amz_neb_regcm_${exp}_mon_2001-2005.nc ${var}_amz_neb_regcm_${exp}_ann_2001-2005.nc

cdo -r -timselavg,3 -selmon,1,2,12 ${var}_namz_regcm_${exp}_mon_2001-2005.nc ${var}_namz_regcm_${exp}_djf_2001-2005.nc
cdo -r -timselavg,3 -selmon,6,7,8  ${var}_namz_regcm_${exp}_mon_2001-2005.nc ${var}_namz_regcm_${exp}_jja_2001-2005.nc
cdo -yearavg ${var}_namz_regcm_${exp}_mon_2001-2005.nc ${var}_namz_regcm_${exp}_ann_2001-2005.nc

cdo -r -timselavg,3 -selmon,1,2,12 ${var}_samz_regcm_${exp}_mon_2001-2005.nc ${var}_samz_regcm_${exp}_djf_2001-2005.nc
cdo -r -timselavg,3 -selmon,6,7,8  ${var}_samz_regcm_${exp}_mon_2001-2005.nc ${var}_samz_regcm_${exp}_jja_2001-2005.nc
cdo -yearavg ${var}_samz_regcm_${exp}_mon_2001-2005.nc ${var}_samz_regcm_${exp}_ann_2001-2005.nc

cdo -r -timselavg,3 -selmon,1,2,12 ${var}_neb_regcm_${exp}_mon_2001-2005.nc ${var}_neb_regcm_${exp}_djf_2001-2005.nc
cdo -r -timselavg,3 -selmon,6,7,8  ${var}_neb_regcm_${exp}_mon_2001-2005.nc ${var}_neb_regcm_${exp}_jja_2001-2005.nc
cdo -yearavg ${var}_neb_regcm_${exp}_mon_2001-2005.nc ${var}_neb_regcm_${exp}_ann_2001-2005.nc
