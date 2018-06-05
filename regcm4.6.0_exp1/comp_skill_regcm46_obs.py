# -*- coding: utf-8 -*-

__author__      = "Leidinice Silva"
__email__       = "leidinicesilvae@gmail.com"
__date__        = "05/26/2018"
__description__ = "This script plot mensal and seasonal anomaly simulation"


import os
import netCDF4
import numpy as np
import matplotlib as mpl 
# mpl.use('Agg')
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import shiftgrid

from datetime import datetime, date
from PyFuncemeClimateTools import PlotMaps as pm
from hidropy.utils.hidropy_utils import create_path
from vol3.nice.codes.PyClimateTools.comp_climate_stats import compute_anomaly
from matplotlib.font_manager import FontProperties

from pltsst import plotmap


# Plot time series per region		 
reg_list = ['A1', 'A2', 'A3', 'A4', 'A5','A6', 'A7', 'A8']

for reg in reg_list:
    print reg

    clim1 = []
    clim2 = []

    for mon in range(0,12):

	# Open model data	 
	model_path = '/vol3/nice/output'
	arq1  = '{0}/pr_amz_neb_regcm_exp1_2001-2005_{1}.nc'.format(model_path, reg)
	data1 = netCDF4.Dataset(arq1)
	var1  = data1.variables['pr'][:]
	lat   = data1.variables['lat'][:]
	lon   = data1.variables['lon'][:]
        fcst  = var1[mon::12][:,:,:]
	fcst_ini1 = np.nanmean(fcst, axis=1)
	fcst_end1 = np.nanmean(fcst_ini1, axis=1)
	clim1.append(hind_end1)

	# Open obs data		 
	obs_path = '/vol3/nice/obs'
	arq2     = '{0}/pre_amz_neb_cru_ts4.01_observation_1979-2010_{1}.nc'.format(obs_path, reg)
	data2    = netCDF4.Dataset(arq2)
	var2     = data2.variables['pre'][:]
	lat      = data2.variables['lat'][:]
	lon      = data2.variables['lon'][:]
        obs      = var2[mon::12][:,:,:]
	obs_ini1 = np.nanmean(obs, axis=1)
	obs_end2 = np.nanmean(obs_ini1, axis=1)
	clim2.append(obs_end2)

    # Plot figure of time series per region
    fig = plt.figure(figsize=(12,6))
    time = np.arange(0, 12)

    a1 = plt.plot(time, clim1, time, clim2)

    plt.title(u'Climatology precipitation time series - {0}'.format(reg), fontsize=16, fontweight='bold')
	
    plt.xlabel(u'Months', fontsize=16, fontweight='bold')
    plt.ylabel(u'Fluxs', fontsize=16, fontweight='bold')

    plt.ylim([-40,40])

    objects = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC']
    plt.xticks(time, objects, fontsize=12)
    plt.grid(True, which='major', linestyle='-.', linewidth='0.5', zorder=0.5)

    font = FontProperties(size=10)
    plt.legend([u'evapr', u'lh',u'qa', u'sh', u'ts', u'ws'],
		loc='best', ncol=2, prop=font)

    path_out = '/vol3/nice/results/regcm4.6.0_exp1'

    if not os.path.exists(path_out):
	create_path(path_out)

    graph_ts = 'plt_time_serie_precipitation_2001-2005_{0}.png'.format(reg)
    plt.savefig(os.path.join(path_out, graph_ts), bbox_inches='tight')
    plt.close()
    raise SystemExit


# Boxplot anual		 
# Open model data	 
model_path = '/vol3/nice/output'
arq1  = '{0}/pr_amz_neb_regcm_exp1_2001-2005_{1}.nc'.format(model_path, reg)
data1 = netCDF4.Dataset(arq1)
var1  = data1.variables['pr'][:]
lat   = data1.variables['lat'][:]
lon   = data1.variables['lon'][:]

# Open obs data	 
obs_path = '/vol3/nice/obs'
arq2     = '{0}/pre_amz_neb_cru_ts4.01_observation_1979-2010_{1}.nc'.format(obs_path, reg)
data2    = netCDF4.Dataset(arq2)
var2     = data2.variables['pre'][:]
lat      = data2.variables['lat'][:]
lon      = data2.variables['lon'][:]

# all months run the list
year_sim = np.nanmean(np.nanmean(var1[:, :, :], axis=1), axis=1)
year_obs = np.nanmean(np.nanmean(var2[:, :, :], axis=1), axis=1)

year_clim_sim = []
year_clim_obs = []

for mon in range(0,372,12):

    mean_year_sim.append(np.nanmean(year_sim[0:12]))
    mean_year_obs.append(np.nanmean(year_obs[0:12]))

# Boxplot figure of time series 
fig = plt.figure(figsize=(34, 12))
date1 = np.arange(1, 5 + 1)
date2 = np.arange(1, 31 + 1)

a = plt.plot(dates1, year_clim_obs)
plt.boxplot(year_clim_sim)
plt.setp(a, linewidth=2, markeredgewidth=2, marker='+', color='black')
plt.title(u'Analysis of annual accumulative rainfall \n RegCM4.3.0 x OBS / 2001-2005', fontsize=34, fontweight='bold')
plt.xlabel(u'Anos', fontsize=34, fontweight='bold')
plt.ylabel(u'Precipitation (mm/m)', fontsize=34, fontweight='bold')
objects = [u'1982', u'1983', u'1984', u'1985', u'1986', u'1987', u'1988', u'1989', u'1990', u'1991', u'1992', u'1993',
           u'1994', u'1995', u'1996', u'1997', u'1998', u'1999', u'2000', u'2001', u'2002', u'2003', u'2004', u'2005',
           u'2006', u'2007', u'2008', u'2009', u'2010', u'2011', u'2012']
plt.xticks(dates, objects)
plt.tick_params(axis='both', which='major', labelsize=20, length=4, width=2, pad=4, labelcolor='k')

font = FontProperties(size=34)
plt.legend(a, [u'OBS'], loc='best', ncol=1, prop=font)

path_out = home + '/vol3/nice/results/regcm4.6.0_exp1'

if not os.path.exists(path_out):
    create_path(path_out)

plt.savefig(os.path.join(path_out, 'boxplot_anual_precipitation_2001-2005.png'.format(grad, paramet)), dpi=100)
plt.close()
raise SystemExit


#Calculate statistics index
jan_sim = var1[0::12][:, :, :]
jan_mean_sim = np.nanmean(jan_sim)
jan_yr_sim = np.nanmean(np.nanmean(jan_sim, axis=1), axis=1)

feb_sim = var1[1::12][:, :, :]
feb_mean_sim = np.nanmean(feb_sim)
feb_yr_sim = np.nanmean(np.nanmean(feb_sim, axis=1), axis=1)

mar_sim = var1[2::12][:, :, :]
mar_mean_sim = np.nanmean(mar_sim)
mar_yr_sim = np.nanmean(np.nanmean(mar_sim, axis=1), axis=1)

apr_sim = var1[3::12][:, :, :]
apr_mean_sim = np.nanmean(apr_sim)
apr_yr_sim = np.nanmean(np.nanmean(apr_sim, axis=1), axis=1)

may_sim = var1[4::12][:, :, :]
may_mean_sim = np.nanmean(may_sim)
may_yr_sim = np.nanmean(np.nanmean(may_sim, axis=1), axis=1)

jun_sim = var1[5::12][:, :, :]
jun_mean_sim = np.nanmean(jun_sim)
jun_yr_sim = np.nanmean(np.nanmean(jun_sim, axis=1), axis=1)

jul_sim = var1[6::12][:, :, :]
jul_mean_sim = np.nanmean(jul_sim)
jul_yr_sim = np.nanmean(np.nanmean(jul_sim, axis=1), axis=1)

aug_sim = var1[7::12][:, :, :]
aug_mean_sim = np.nanmean(aug_sim)
aug_yr_sim = np.nanmean(np.nanmean(aug_sim, axis=1), axis=1)

sep_sim = var1[8::12][:, :, :]
sep_mean_sim = np.nanmean(sep_sim)
sep_yr_sim = np.nanmean(np.nanmean(sep_sim, axis=1), axis=1)

oct_sim = var1[9::12][:, :, :]
oct_mean_sim = np.nanmean(oct_sim)
oct_yr_sim = np.nanmean(np.nanmean(oct_sim, axis=1), axis=1)

nov_sim = var1[10::12][:, :, :]
nov_mean_sim = np.nanmean(nov_sim)
nov_yr_sim = np.nanmean(np.nanmean(nov_sim, axis=1), axis=1)

dec_sim = var1[11::12][:, :, :]
dec_mean_sim = np.nanmean(dec_sim)
dec_yr_sim = np.nanmean(np.nanmean(dec_sim, axis=1), axis=1)


jan_obs = var2[0::12][:, :, :]
jan_mean_obs = np.nanmean(jan_obs)
jan_yr_obs = np.nanmean(np.nanmean(jan_obs, axis=1), axis=1)

feb_obs = var2[1::12][:, :, :]
feb_mean_obs = np.nanmean(feb_obs)
feb_yr_obs = np.nanmean(np.nanmean(feb_obs, axis=1), axis=1)

mar_obs = var2[2::12][:, :, :]
mar_mean_obs = np.nanmean(mar_obs)
mar_yr_obs = np.nanmean(np.nanmean(mar_obs, axis=1), axis=1)

apr_obs = var2[3::12][:, :, :]
apr_mean_obs = np.nanmean(apr_obs)
apr_yr_obs = np.nanmean(np.nanmean(apr_obs, axis=1), axis=1)

may_obs = var2[4::12][:, :, :]
may_mean_obs = np.nanmean(may_obs)
may_yr_obs = np.nanmean(np.nanmean(may_obs, axis=1), axis=1)

jun_obs = var2[5::12][:, :, :]
jun_mean_obs = np.nanmean(jun_obs)
jun_yr_obs = np.nanmean(np.nanmean(jun_obs, axis=1), axis=1)

jul_obs = var2[6::12][:, :, :]
jul_mean_obs = np.nanmean(jul_obs)
jul_yr_obs = np.nanmean(np.nanmean(jul_obs, axis=1), axis=1)

aug_obs = var2[7::12][:, :, :]
aug_mean_obs = np.nanmean(aug_obs)
aug_yr_obs = np.nanmean(np.nanmean(aug_obs, axis=1), axis=1)

sep_obs = var2[8::12][:, :, :]
sep_mean_obs = np.nanmean(sep_obs)
sep_yr_obs = np.nanmean(np.nanmean(sep_obs, axis=1), axis=1)

oct_obs = var2[9::12][:, :, :]
oct_mean_obs = np.nanmean(oct_obs)
oct_yr_obs = np.nanmean(np.nanmean(oct_obs, axis=1), axis=1)

nov_obs = variable2[10::12][:, :, :]
nov_mean_obs = np.nanmean(nov_obs)
nov_yr_obs = np.nanmean(np.nanmean(nov_obs, axis=1), axis=1)

dec_obs = var2[11::12][:, :, :]
dec_mean_obs = np.nanmean(dec_obs)
dec_yr_obs = np.nanmean(np.nanmean(dec_obs, axis=1), axis=1)	

# Calculate statistics indices
anom_jan = compute_anomaly(jan_yr_sim, jan_yr_obs)
anom_feb = compute_anomaly(feb_yr_sim, feb_yr_obs)
anom_mar = compute_anomaly(mar_yr_sim, mar_yr_obs)
anom_apr = compute_anomaly(apr_yr_sim, apr_yr_obs)
anom_may = compute_anomaly(may_yr_sim, may_yr_obs)
anom_jun = compute_anomaly(jun_yr_sim, jun_yr_obs)
anom_jul = compute_anomaly(jul_yr_sim, jul_yr_obs)
anom_aug = compute_anomaly(aug_yr_sim, aug_yr_obs)
anom_sep = compute_anomaly(sep_yr_sim, sep_yr_obs)
anom_oct = compute_anomaly(oct_yr_sim, oct_yr_obs)
anom_nov = compute_anomaly(nov_yr_sim, nov_yr_obs)
anom_dec = compute_anomaly(dec_yr_sim, dec_yr_obs)

corr_jan = compute_corr(jan_yr_sim, jan_yr_obs)
corr_feb = compute_corr(feb_yr_sim, feb_yr_obs)
corr_mar = compute_corr(mar_yr_sim, mar_yr_obs)
corr_apr = compute_corr(apr_yr_sim, apr_yr_obs)
corr_may = compute_corr(may_yr_sim, may_yr_obs)
corr_jun = compute_corr(jun_yr_sim, jun_yr_obs)
corr_jul = compute_corr(jul_yr_sim, jul_yr_obs)
corr_aug = compute_corr(aug_yr_sim, aug_yr_obs)
corr_sep = compute_corr(sep_yr_sim, sep_yr_obs)
corr_oct = compute_corr(oct_yr_sim, oct_yr_obs)
corr_nov = compute_corr(nov_yr_sim, nov_yr_obs)
corr_dec = compute_corr(dec_yr_sim, dec_yr_obs)

bias_jan = compute_bias(jan_yr_sim, jan_yr_obs)
bias_feb = compute_bias(feb_yr_sim, feb_yr_obs)
bias_mar = compute_bias(mar_yr_sim, mar_yr_obs)
bias_apr = compute_bias(apr_yr_sim, apr_yr_obs)
bias_may = compute_bias(may_yr_sim, may_yr_obs)
bias_jun = compute_bias(jun_yr_sim, jun_yr_obs)
bias_jul = compute_bias(jul_yr_sim, jul_yr_obs)
bias_aug = compute_bias(aug_yr_sim, aug_yr_obs)
bias_sep = compute_bias(sep_yr_sim, sep_yr_obs)
bias_oct = compute_bias(oct_yr_sim, oct_yr_obs)
bias_nov = compute_bias(nov_yr_sim, nov_yr_obs)
bias_dec = compute_bias(dec_yr_sim, dec_yr_obs)

rmse_jan = compute_rmse(jan_yr_sim, jan_yr_obs)
rmse_feb = compute_rmse(feb_yr_sim, feb_yr_obs)
rmse_mar = compute_rmse(mar_yr_sim, mar_yr_obs)
rmse_apr = compute_rmse(apr_yr_sim, apr_yr_obs)
rmse_may = compute_rmse(may_yr_sim, may_yr_obs)
rmse_jun = compute_rmse(jun_yr_sim, jun_yr_obs)
rmse_jul = compute_rmse(jul_yr_sim, jul_yr_obs)
rmse_aug = compute_rmse(aug_yr_sim, aug_yr_obs)
rmse_sep = compute_rmse(sep_yr_sim, sep_yr_obs)
rmse_oct = compute_rmse(oct_yr_sim, oct_yr_obs)
rmse_nov = compute_rmse(nov_yr_sim, nov_yr_obs)
rmse_dec = compute_rmse(dec_yr_sim, dec_yr_obs)

nash_jan = compute_nash(jan_yr_sim, jan_yr_obs)
nash_feb = compute_nash(feb_yr_sim, feb_yr_obs)
nash_mar = compute_nash(mar_yr_sim, mar_yr_obs)
nash_apr = compute_nash(apr_yr_sim, apr_yr_obs)
nash_may = compute_nash(may_yr_sim, may_yr_obs)
nash_jun = compute_nash(jun_yr_sim, jun_yr_obs)
nash_jul = compute_nash(jul_yr_sim, jul_yr_obs)
nash_aug = compute_nash(aug_yr_sim, aug_yr_obs)
nash_sep = compute_nash(sep_yr_sim, sep_yr_obs)
nash_oct = compute_nash(oct_yr_sim, oct_yr_obs)
nash_nov = compute_nash(nov_yr_sim, nov_yr_obs)
nash_dec = compute_nash(dec_yr_sim, dec_yr_obs)

anom_mon = np.array([anom_jan, anom_feb, anom_mar, anom_apr, anom_may, anom_jun, anom_jul, anom_aug, anom_sep, anom_oct, anom_nov, anom_dec])

corr_mon = np.array([corr_jan, corr_feb, corr_mar, corr_apr, corr_may, corr_jun, corr_jul, corr_aug, corr_sep, corr_oct, corr_nov, corr_dec])

bias_mon = np.array([bias_jan, bias_feb, bias_mar, bias_apr, bias_may, bias_jun, bias_jul, bias_aug, bias_sep, bias_oct, bias_nov, bias_dec])

rmse_mon = np.array([rmse_jan, rmse_feb, rmse_mar, rmse_apr, rmse_may, rmse_jun, rmse_jul, rmse_aug, rmse_sep, rmse_oct, rmse_nov, rmse_dec])

nash_mon = np.array([nash_jan, nash_feb, nash_mar, nash_apr, nash_may, nash_jun, nash_jul, nash_aug, nash_sep, nash_oct, nash_nov, nash_dec])

tab = tt.Texttable(max_width=200)
tab_inform = [[]]

tab.add_rows(tab_inform)
tab.set_cols_align(['c', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c'])

tab.header(['MON', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'])

table = str(tab.draw())

file_name = 'best_corr_all_basins_{0}_mon.asc'.format(anom_mon)
file_save = open(file_name, 'w')
file_save.write(table)
file_save.close()


# RegCM4.3.0 corrected analises
year_olam_cor = gamma_correction(year_sim, year_obs, year_sim)

dates = pd.date_range('1982-01-01', '2012-12-31', freq='M')
OLAM = pd.Series(year_olam_cor, index=dates)
OBS = pd.Series(year_obs, index=dates)
obsolam = pd.DataFrame({'OLAMv.3.3_cor': OLAM, 'OBS': OBS})
pyplot.figure(figsize=(12, 8))

pyplot.subplot(2, 1, 1)
obsolam['1982':'2012'].plot(ax=pyplot.gca())
plt.title(u'Análise das precipitações médias mensais \n OLAMv.3.3_{0}_{1}_cor x OBS  - 1982_2012'
           .format(grad, paramet.upper()), fontsize=20, fontweight='bold')
plt.xlabel(u'Anos', fontweight='bold')
plt.ylabel(u'Precipitação (mm/m)', fontweight='bold')
font = FontProperties(size=10)
plt.legend([u'OLAMv.3.3', u'OBS'], loc='best', ncol=2, prop=font)

pyplot.subplot(2, 1, 2)
obsolam.plot(kind='scatter', x='OLAMv.3.3_cor', y='OBS', ax=pyplot.gca())
plt.xlabel(u'OLAMv.3.3_cor (mm/m)', fontweight='bold')
plt.ylabel(u'Observado (mm/m)', fontweight='bold')
plt.savefig(os.path.join(path_out, 'cor_precip_anual_obs_sim_{0}_{1}.png'.format(grad, paramet)), dpi=100)

