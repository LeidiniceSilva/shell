
var="tas"
sim="Amon_HadGEM2-ES_hist_r1i1p1"
tim="ann"

echo ${var}
echo ${sim}
echo ${tim}

obs_dir="/home/nice/Documents/dataset/obs/reg_exp1"
sim_dir="/home/nice/Documents/dataset/gcm/reg_exp1/hist"

#~ cdo -r -timselavg,3 -selmon,9,10,11 pr_amz_neb_Amon_HadGEM2-ES_hist_r1i1p1_mon_1986-2005_lonlat_seamask.nc pr_amz_neb_Amon_HadGEM2-ES_hist_r1i1p1_son_1986-2005_lonlat_seamask.nc
#~ cdo -r -timselavg,3 -selmon,6,7,8 pr_amz_neb_Amon_HadGEM2-ES_hist_r1i1p1_mon_1986-2005_lonlat_seamask.nc pr_amz_neb_Amon_HadGEM2-ES_hist_r1i1p1_jja_1986-2005_lonlat_seamask.nc
#~ cdo -r -timselavg,3 -selmon,3,4,5 pr_amz_neb_Amon_HadGEM2-ES_hist_r1i1p1_mon_1986-2005_lonlat_seamask.nc pr_amz_neb_Amon_HadGEM2-ES_hist_r1i1p1_mam_1986-2005_lonlat_seamask.nc
#~ cdo -r -timselavg,3 -selmon,1,2,12 pr_amz_neb_Amon_HadGEM2-ES_hist_r1i1p1_mon_1986-2005_lonlat_seamask.nc pr_amz_neb_Amon_HadGEM2-ES_hist_r1i1p1_djf_1986-2005_lonlat_seamask.nc
#~ cdo yearmean pr_amz_neb_Amon_HadGEM2-ES_hist_r1i1p1_mon_1986-2005_lonlat_seamask.nc pr_amz_neb_Amon_HadGEM2-ES_hist_r1i1p1_ann_1986-2005_lonlat_seamask.nc

#~ cdo sellonlatbox,-68,-52,-12,-3 ${obs_dir}/${var}_amz_neb_cru_ts4.04_obs_${tim}_1986-2005_lonlat.nc ${obs_dir}/${var}_samz_cru_ts4.04_obs_${tim}_1986-2005_lonlat.nc
#~ cdo sellonlatbox,-40,-35,-16,-3 ${obs_dir}/${var}_amz_neb_cru_ts4.04_obs_${tim}_1986-2005_lonlat.nc ${obs_dir}/${var}_eneb_cru_ts4.04_obs_${tim}_1986-2005_lonlat.nc
#~ cdo sellonlatbox,-50.5,-42.5,-15,-2.5 ${obs_dir}/${var}_amz_neb_cru_ts4.04_obs_${tim}_1986-2005_lonlat.nc ${obs_dir}/${var}_matopiba_cru_ts4.04_obs_${tim}_1986-2005_lonlat.nc

cdo sellonlatbox,-68,-52,-12,-3 ${sim_dir}/${var}_amz_neb_${sim}_${tim}_1986-2005_lonlat_seamask.nc ${sim_dir}/${var}_samz_${sim}_${tim}_1986-2005_lonlat_seamask.nc
cdo sellonlatbox,-40,-35,-16,-3 ${sim_dir}/${var}_amz_neb_${sim}_${tim}_1986-2005_lonlat_seamask.nc ${sim_dir}/${var}_eneb_${sim}_${tim}_1986-2005_lonlat_seamask.nc
cdo sellonlatbox,-50.5,-42.5,-15,-2.5 ${sim_dir}/${var}_amz_neb_${sim}_${tim}_1986-2005_lonlat_seamask.nc ${sim_dir}/${var}_matopiba_${sim}_${tim}_1986-2005_lonlat_seamask.nc







