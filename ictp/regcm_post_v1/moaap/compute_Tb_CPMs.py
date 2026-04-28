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
domain = 'CAR-4'

if domain == 'CAR-4':
    path_in = '/leonardo_work/ICT26_ESP/CORDEX-CMIP6/DD/CAR-4/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/rlut/v20260308'
elif domain == 'CSAM-3':
    path_in = '/leonardo_work/ICT26_ESP/CORDEX-CMIP6/DD/CSAM-3/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/rlut'
elif domain == 'EURR-3':
    path_in = '/leonardo_work/ICT26_ESP/CORDEX-CMIP6/DD/CAR-4/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/rlut/v20260308'
else:
    raise ValueError('Unknown domain: {0}'.format(domain))

# Output path
path_out = '/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/{0}/input/Tb'.format(domain)

# File list
files = sorted(glob.glob(path_in + '/rlut_*.nc'))

# Constants
sigma = 5.670374419e-8 * units('W / m^2 / K^4')
emis = 0.97

for f in files:
	print('Processing: {0}'.format(f))

	# Open dataset
	ds = xr.open_dataset(f) 
	rlut = ds['rlut'] * units('W/m^2')

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
	out = os.path.join(path_out, fname.replace('rlut', 'Tb'))
	ds[['Tb']].to_netcdf(out)


