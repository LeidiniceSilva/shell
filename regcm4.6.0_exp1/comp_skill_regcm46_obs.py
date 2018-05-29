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


# Open model and obs data		 
model_path = '/vol3/nice/output'
obs_path   = '/vol3/nice/obs'

arq1  = '{0}/pr_amz_neb_regcm_exp1_2001-2005.nc'.format(model_path)
data1 = netCDF4.Dataset(arq1)
var1  = data1.variables['pr'][:]
lat   = data1.variables['lat'][:]
lon   = data1.variables['lon'][:]

arq2  = '{0}/pre_amz_neb_cru_ts4.01_observation_1979-2010.nc'.format(obs_path)
data2 = netCDF4.Dataset(arq2)
var2  = data2.variables['pre'][:]
lat   = data2.variables['lat'][:]
lon   = data2.variables['lon'][:]


# Plot time series per region		 
reg_ninos = ['A1', 'A2', 'A3', 'A4', 'A5','A6', 'A7', 'A8']

for reg_nino in reg_ninos:
	print reg_nino
				
	path1 = "/home/leidinice/documentos/oaflux/dados/evapr/"
	file1 = 'evapr_oaflux_2017rt_{0}.nc'.format(reg_nino)
	data1 = netCDF4.Dataset(str(path1) + file1)
	var1  = data1.variables['evapr'][:,:,:]
	lat = data1.variables['lat'][:] 
	lon = data1.variables['lon'][:] 	
	fcst_ini1 = np.nanmean(var1, axis=1)
	fcst_end1 = np.nanmean(fcst_ini1, axis=1)
		
	path2 = "/home/leidinice/documentos/oaflux/dados/lh/"
	file2 = 'lh_oaflux_2017rt_{0}.nc'.format(reg_nino)
	data2 = netCDF4.Dataset(str(path2) + file2)
	var2  = data2.variables['lhtfl'][:,:,:]
	lat = data2.variables['lat'][:] 
	lon = data2.variables['lon'][:] 	
	fcst_ini2 = np.nanmean(var2, axis=1)
	fcst_end2 = np.nanmean(fcst_ini2, axis=1)

	path3 = "/home/leidinice/documentos/oaflux/dados/qa/"
	file3 = 'qa_oaflux_2017rt_{0}.nc'.format(reg_nino)
	data3 = netCDF4.Dataset(str(path3) + file3)
	var3  = data3.variables['hum2m'][:,:,:]
	lat = data3.variables['lat'][:] 
	lon = data3.variables['lon'][:] 	
	fcst_ini3 = np.nanmean(var3, axis=1)
	fcst_end3 = np.nanmean(fcst_ini3, axis=1)

	path4 = "/home/leidinice/documentos/oaflux/dados/sh/"
	file4 = 'sh_oaflux_2017rt_{0}.nc'.format(reg_nino)
	data4 = netCDF4.Dataset(str(path4) + file4)
	var4  = data4.variables['shtfl'][:,:,:]
	lat = data4.variables['lat'][:] 
	lon = data4.variables['lon'][:] 	
	fcst_ini4 = np.nanmean(var4, axis=1)
	fcst_end4 = np.nanmean(fcst_ini4, axis=1)

	path5 = "/home/leidinice/documentos/oaflux/dados/ts/"
	file5 = 'ts_oaflux_2017rt_{0}.nc'.format(reg_nino)
	data5 = netCDF4.Dataset(str(path5) + file5)
	var5  = data5.variables['tmpsf'][:,:,:]
	lat = data5.variables['lat'][:] 
	lon = data5.variables['lon'][:] 	
	fcst_ini5 = np.nanmean(var5, axis=1)
	fcst_end5 = np.nanmean(fcst_ini5, axis=1)
		
	path6 = "/home/leidinice/documentos/oaflux/dados/ws/"
	file6 = 'ws_oaflux_2017rt_{0}.nc'.format(reg_nino)
	data6 = netCDF4.Dataset(str(path6) + file6)
	var6  = data6.variables['wnd10'][:,:,:]
	lat = data6.variables['lat'][:] 
	lon = data6.variables['lon'][:] 	
	fcst_ini6 = np.nanmean(var6, axis=1)
	fcst_end6 = np.nanmean(fcst_ini6, axis=1)

	clim1 = []
	clim2 = []
	clim3 = []
	clim4 = []
	clim5 = []
	clim6 = []

	for mon in range(0,6):

		# Open and reading files
		path1 = "/home/leidinice/documentos/oaflux/dados/evapr/"
		file_hind1 = 'evapr_oaflux_8110.nc'.format(reg_nino)
		data_hind1 = netCDF4.Dataset(str(path1) + file_hind1)
		var_hind1  = data_hind1.variables['evapr'][:,:,:]
		lat = data_hind1.variables['lat'][:] 
		lon = data_hind1.variables['lon'][:]
		hind1 = var_hind1[mon::12][:,:,:]
		
		hind_ini1 = np.nanmean(hind1, axis=1)
		hind_end1 = np.nanmean(hind_ini1, axis=1)
		clim1.append(hind_end1)
		
		path2 = "/home/leidinice/documentos/oaflux/dados/lh/"
		file_hind2 = 'lh_oaflux_8110_{0}.nc'.format(reg_nino)
		data_hind2 = netCDF4.Dataset(str(path2) + file_hind2)
		var_hind2  = data_hind2.variables['lhtfl'][:,:,:]
		lat = data_hind2.variables['lat'][:] 
		lon = data_hind2.variables['lon'][:]
		hind2 = var_hind1[mon::12][:,:,:]
		
		hind_ini2 = np.nanmean(hind2, axis=1)
		hind_end2 = np.nanmean(hind_ini2, axis=1)
		clim2.append(hind_end2)
		
		path3 = "/home/leidinice/documentos/oaflux/dados/qa/"
		file_hind3 = 'qa_oaflux_8110_{0}.nc'.format(reg_nino)
		data_hind3 = netCDF4.Dataset(str(path3) + file_hind3)
		var_hind3  = data_hind3.variables['hum2m'][:,:,:]
		lat = data_hind3.variables['lat'][:] 
		lon = data_hind3.variables['lon'][:]
		hind3 = var_hind3[mon::12][:,:,:]

		hind_ini3 = np.nanmean(hind3, axis=1)
		hind_end3 = np.nanmean(hind_ini3, axis=1)
		clim3.append(hind_end3)
				
		path4 = "/home/leidinice/documentos/oaflux/dados/sh/"
		file_hind4 = 'sh_oaflux_8110_{0}.nc'.format(reg_nino)
		data_hind4 = netCDF4.Dataset(str(path4) + file_hind4)
		var_hind4  = data_hind4.variables['shtfl'][:,:,:]
		lat = data_hind4.variables['lat'][:] 
		lon = data_hind4.variables['lon'][:]
		hind4 = var_hind4[mon::12][:,:,:]

		hind_ini4 = np.nanmean(hind4, axis=1)
		hind_end4 = np.nanmean(hind_ini4, axis=1)
		clim4.append(hind_end4)

		path5 = "/home/leidinice/documentos/oaflux/dados/ts/"
		file_hind5 = 'ts_oaflux_8110_{0}.nc'.format(reg_nino)
		data_hind5 = netCDF4.Dataset(str(path5) + file_hind5)
		var_hind5  = data_hind5.variables['tmpsf'][:,:,:]
		lat = data_hind5.variables['lat'][:] 
		lon = data_hind5.variables['lon'][:]
		hind5 = var_hind5[mon::12][:,:,:]

		hind_ini5 = np.nanmean(hind5, axis=1)
		hind_end5 = np.nanmean(hind_ini5, axis=1)
		clim5.append(np.squeeze(hind_end5))
	
		path6 = "/home/leidinice/documentos/oaflux/dados/ws/"
		file_hind6 = 'ws_oaflux_8110_{0}.nc'.format(reg_nino)
		data_hind6 = netCDF4.Dataset(str(path6) + file_hind6)
		var_hind6  = data_hind6.variables['wnd10'][:,:,:]
		lat = data_hind6.variables['lat'][:] 
		lon = data_hind6.variables['lon'][:]
		hind6 = var_hind6[mon::12][:,:,:]

		hind_ini6 = np.nanmean(hind6, axis=1)
		hind_end6 = np.nanmean(hind_ini6, axis=1)
		clim6.append(hind_end6)
	
	anom_pad1 = compute_standard_anomaly(fcst_end1, clim1)
	anom_pad2 = compute_standard_anomaly(fcst_end2, clim2)
	anom_pad3 = compute_standard_anomaly(fcst_end3, clim3)
	anom_pad4 = compute_standard_anomaly(fcst_end4, clim4)
	anom_pad5 = compute_standard_anomaly(fcst_end5, clim5)
	anom_pad6 = compute_standard_anomaly(fcst_end6, clim6)
	
	# Plot figure of time siries per nino region
	fig = plt.figure(figsize=(12,6))
	time = np.arange(1, 6 + 1)

	a1 = plt.plot(time, anom_pad1, time, anom_pad2, time, anom_pad3, 
				  time, anom_pad4 ,time, anom_pad5, time, anom_pad6)

	l1, l2, l3, l4, l5, l6 = a1
	plt.setp(l1,  linewidth=2, markeredgewidth=1, marker='o', color='black')
	plt.setp(l2,  linewidth=2, markeredgewidth=1, marker='o', color='blue')
	plt.setp(l3,  linewidth=2, markeredgewidth=1, marker='o', color='red')
	plt.setp(l4,  linewidth=2, markeredgewidth=1, marker='o', color='green')
	plt.setp(l5,  linewidth=2, markeredgewidth=1, marker='o', color='orange')
	plt.setp(l6,  linewidth=2, markeredgewidth=1, marker='o', color='gray')

	plt.title(u'Air-water interface anomaly fluxs - {0}'.format(reg_nino.upper()),
			  fontsize=16, fontweight='bold')
				
	plt.xlabel(u'Months', fontsize=16, fontweight='bold')
	plt.ylabel(u'Fluxs', fontsize=16, fontweight='bold')
	
	plt.ylim([-40,40])

	objects = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN']
	plt.xticks(time, objects, fontsize=12)
	plt.grid(True, which='major', linestyle='-.', linewidth='0.5', zorder=0.5)

	font = FontProperties(size=10)
	plt.legend([u'evapr', u'lh',u'qa', u'sh', u'ts', u'ws'],
				loc='best', ncol=2, prop=font)

	path_out = "/home/leidinice/documentos/oaflux/results/ts_reg/"

	if not os.path.exists(path_out):
		create_path(path_out)

	graph_ts = 'plt_time_serie_oaflux_{0}_2017.png'.format(reg_nino)
	plt.savefig(os.path.join(path_out, graph_ts), bbox_inches='tight')
	
	plt.close()
	
	raise SystemExit
	
	
# Plot map per region
var_names = ['evapr', 'lh', 'qa', 'sh', 'ts', 'ws']

for var_name in var_names:
	print var_name
	
	dic_vars  = {u'evapr': u'evapr',
				 u'lh': u'lhtfl',
				 u'qa': u'hum2m',
				 u'sh': u'shtfl',
				 u'ts': u'tmpsf',
				 u'ws': u'wnd10'}

	dic_title_vars  = {u'evapr': u'Evaporation (mm/month)',
					   u'lh': u'Latent Heat Flux (W/m)',
					   u'qa': u'Air Humidity 2m (g/kg)',
					   u'sh': u'Sensible Feat Flux (W/m)',
					   u'ts': u'Sea Surface Temperature (°C)',
					   u'ws': u'Wind Speed 10m (m/s)'}			   
			   
	for mon in range(0,6):
		month = mon+1
		
		target_date = datetime(2017, month, 01)
		str_mon = target_date.strftime("%b").lower()
		print str_mon

		dic_mon = {u'jan': u'jan',
				   u'fev': u'feb',
				   u'mar': u'mar',
				   u'abr': u'apr',
				   u'mai': u'may',
				   u'jun': u'jun',
				   u'jul': u'jul'}

		# Open and reading files
		path_in = "/home/leidinice/documentos/oaflux/dados/{0}/".format(var_name)

		file_hind = '{0}_oaflux_8110.nc'.format(var_name)
		data_hind = netCDF4.Dataset(str(path_in) + file_hind)
		var_hind  = data_hind.variables[dic_vars[var_name]][:,:,:]
		lat = data_hind.variables['lat'][:] 
		lon = data_hind.variables['lon'][:]
		mon_clim = var_hind[mon::12][:,:,:]

		file_fcst = '{0}_oaflux_2017rt.nc'.format(var_name)
		data_fcst = netCDF4.Dataset(str(path_in) + file_fcst)
		var_fcst  = data_fcst.variables[dic_vars[var_name]][:,:,:]
		lat = data_fcst.variables['lat'][:] 
		lon = data_fcst.variables['lon'][:]
		mon_fcst = var_fcst[mon,:,:]
		
		# Calculate anomaly	 
		ano = compute_anomaly(mon_fcst, mon_clim)
		dvar, dlonew = shiftgrid(20., ano, lon, start=False)
					 
		path_out2  = "/home/leidinice/documentos/oaflux/results/anom_maps/{0}".format(var_name)
		
		if not os.path.exists(path_out2):
			create_path(path_out2)
		
		# Plot anomaly		
		fig_title = u'{0} - Anomaly Flux - {1}/2017'.format(dic_title_vars[var_name],
		    dic_mon[str_mon].upper(), fontsize=100, fontweight='bold')
		    
		dic_levs_vars  = {u'evapr': np.linspace(-200, 200, 13),
							u'lh': np.linspace(-200, 200, 13),
							u'qa': np.linspace(-2.5, 2.5, 13),
							u'sh': np.linspace(-20, 20, 13),
							u'ts': np.linspace(-3, 3, 13),
							u'ws': np.linspace(-5, 5, 13)}
				
		my_colors = ('#000044', '#0033FF', '#007FFF', '#0099FF', '#00B2FF', '#00CCFF', '#FFFFFF',
					 '#FFFFFF', '#FFCC00', '#FF9900', '#FF7F00', '#FF3300', '#A50000', '#B48C82')
					 
		fig_out = (os.path.join(path_out2, '{0}_anomaly_oaflux_{1}.png' \
		    .format(var_name, dic_mon[str_mon])))
		
		plotmap(dvar, lat, dlonew, barloc='bottom', barlevs=dic_levs_vars[var_name],
			barcolor=my_colors, barinf='both', fig_title=fig_title, fig_name=fig_out)

