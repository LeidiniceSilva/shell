# -*- coding: utf-8 -*-

__author__      = "Leidinice Silva"
__email__       = "leidinicesilva@gmail.com"
__date__        = "March 17, 2026"
__description__ = "This script compute Tb"

import os
import glob
import numpy as np
import xarray as xr
import metpy.xarray    
       
from metpy.units import units

# Domain name
domain = 'CSAM-3'

# Paths
path_in = '/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/ERA5'
path_out = '/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/ERA5/{0}'.format(domain)

# File list
files = sorted(glob.glob(path_in + '/avg_tnlwrf_{0}_ERA5_reanalysis_1hr_2000-2009.nc'.format(domain)))

# Constants
sigma = 5.670374419e-8 * units('W / m^2 / K^4')
emis = 0.97

for f in files:
	print('Processing: {0}'.format(f))

	# Open dataset
	ds = xr.open_dataset(f) 
	rlut = ds['avg_tnlwrf'] * units('W/m^2')

	# Compute Tb
	Tb = (rlut / (emis * sigma))**0.25
	Tb = Tb.metpy.convert_units('kelvin')

	# Save to dataset
	ds['Tb'] = Tb
	ds['Tb'].attrs = {
		'long_name': 'Brightness temperature',
		'units': 'K',
		'emissivity': emis,
		'method': 'Stefan-Boltzmann inversion'
		}

	# Save Tb
	fname = os.path.basename(f) 
	out = os.path.join(path_out, fname.replace('avg_tnlwrf', 'Tb'))
	ds[['Tb']].to_netcdf(out)


