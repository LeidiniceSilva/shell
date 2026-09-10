# -*- coding: utf-8 -*-

__author__      = "Leidinice Silva"
__email__       = "leidinicesilva@gmail.com"
__date__        = "March 17, 2026"
__description__ = "This script compute Tb"

import os
import glob
import argparse
import numpy as np
import xarray as xr
import metpy.xarray    
       
from metpy.units import units

# Domain name
parser = argparse.ArgumentParser()
parser.add_argument('--domain', required=True, help='Years')
args = parser.parse_args()
domain = args.domain

if domain == 'CAR-4':
    path_in = '/leonardo_work/ICT26_ESP/jdeleeuw/CAR-4/ERA5/high_soil_moisture_OCN/ERA5/CAR-4/postproc/CORDEX-CMIP6/DD/CAR-4/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/rlut'
elif domain == 'CSAM-3':
    path_in = '/leonardo_work/ICT26_ESP/CORDEX-CMIP6/DD/CSAM-3/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/rlut'
elif domain == 'EURR-3':
    path_in = '/leonardo_work/ICT26_ESP/CORDEX-CMIP6/DD/EURR-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/rlut/v20251218'
    #path_in = '/leonardo_work/ICT26_ESP/CORDEX-CMIP6/DD/EURR-3/ICTP/EC-Earth3-Veg/historical/r1i1p1f1/RegCM5-0/v1-r1/1hr/rlut/v20250725'
else:
    raise ValueError('Unknown domain: {0}'.format(domain))

# Output path
path_out = '/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/paper/dataset/CPMs/ICTP/{0}/historical/ERA5/preproc'.format(domain)
#path_out = '/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/paper/dataset/CPMs/ICTP/{0}/historical/ECEarth/preproc'.format(domain)

# All files
all_files = sorted(glob.glob(path_in + '/rlut_*.nc'))

# Filter files where start year is between 2000 and 2009
files = []
for f in all_files:
    fname = os.path.basename(f)
    # Start year from: ..._1hr_YYYYMMDDHHMM-YYYYMMDDHHMM.nc
    start_time_str = fname.split('_')[-1].split('-')[0]
    start_year = int(start_time_str[:4])
    
    if 2000 <= start_year <= 2009:
        files.append(f)

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


