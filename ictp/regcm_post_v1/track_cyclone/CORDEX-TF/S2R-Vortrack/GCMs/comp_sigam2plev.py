#!/usr/bin/env python3

__author__      = "Leidinice Silva"
__email__       = "leidinicesilva@gmail.com"
__date__        = "Sept 25, 2025"
__description__ = "This script convert sigma to pressure level"

import xarray as xr
import numpy as np
import os

# Paths and files
print('Paths and files')
file_in  = '/leonardo_work/ICT25_ESP/RCMDATA/cmip6/cmip6/CMIP/NCC/NorESM2-MM/historical/r1i1p1f1/6hrLev/ua/gn/v20191108/ua_6hrLev_NorESM2-MM_historical_r1i1p1f1_gn_200001010300-200912312100.nc'
path_out = '/leonardo/home/userexternal/mdasilva/leonardo_scratch'
file_out   = '{0}/ua_6hrPLev_NorESM2-MM_historical_r1i1p1f1_gn_200001010300-200912312100.nc'.format(path_out)

# Open dataset
print('Open dataset')
ds = xr.open_dataset(file_in)
ua = ds['ua']        
ps = ds['ps']         
a = ds['a']           
b = ds['b']           
p0 = 100000.0         

# Compute pressure at model levels
print('Compute pressure at model levels')
plev_model = a * p0 + b * ps
plev_model_da = plev_model.broadcast_like(ua)

# Define levels
print('Define vertical levels')
target_plevs = np.array([
    100000,97500,95000,92500,90000,87500,85000,82500,
    80000,77500,75000,70000,65000,60000,55000,50000,
    45000,40000,35000,30000,25000,22500,20000,17500,
    15000,12500,10000,7000,5000,3000,2000,1000
], dtype=float)

# Interpolation function
print('Compute interpolation function')
def interp_fill(var_profile, p_profile, target):

    import numpy as np

    mask = np.isfinite(var_profile) & np.isfinite(p_profile)
    if mask.sum() == 0:
        return np.full(target.shape, np.nan)

    p = p_profile[mask]
    v = var_profile[mask]
    order = np.argsort(p)
    p_sorted = p[order]
    v_sorted = v[order]

    interp = np.interp(target, p_sorted, v_sorted, left=np.nan, right=np.nan)

    lowest_value = v_sorted[-1]
    below_mask = target > p_sorted[-1]  
    interp[below_mask] = lowest_value

    return interp

# Apply function
print('Apply function and filling the missing data')
ua_on_pressure = xr.apply_ufunc(
    interp_fill,
    ua,
    plev_model_da,
    input_core_dims=[['lev'], ['lev']],
    output_core_dims=[['plev']],
    vectorize=True,
    dask='parallelized',
    output_dtypes=[ua.dtype],
    kwargs={'target': target_plevs}
)

# Create dataset
print('Create dataset')
ds_out = xr.Dataset()

# Add variable with correct attributes
print('Add variable with correct attributes')
ds_out['ua'] = ua_on_pressure.transpose('time', 'plev', 'lat', 'lon')

# Ajust attributes
print('Ajust attributes')
ds_out['ua'].attrs = {
    'long_name': 'Zonal wind',
    'units': 'm s**-1', 
    'standard_name': 'eastward_wind'
}

# Corrected attributes
print('Corrected attributes')
ds_out = ds_out.assign_coords({
    "plev": (["plev"], target_plevs, {
        "long_name": "pressure",
        "units": "Pa",
        "positive": "down",
        "axis": "Z",
        "standard_name": "air_pressure"
    }),
    "lat": (["lat"], ua_on_pressure["lat"].values.astype(float), {
        "long_name": "latitude",
        "units": "degrees_north",
        "axis": "Y",
        "standard_name": "latitude"
    }),
    "lon": (["lon"], ua_on_pressure["lon"].values.astype(float), {
        "long_name": "longitude", 
        "units": "degrees_east",
        "axis": "X",
        "standard_name": "longitude"
    }),
    "time": (["time"], ua_on_pressure["time"].values, {
        "axis": "T",
        "standard_name": "time"
    })
})

# Remove bad attributes
print('Remove bad attributes')
if 'units' in ds_out['time'].attrs:
    del ds_out['time'].attrs['units']
if 'calendar' in ds_out['time'].attrs:
    del ds_out['time'].attrs['calendar']

# Global attributes
print('Global attributes')
ds_out.attrs = {
    'Conventions': 'CF-1.6',
    'title': 'Interpolated zonal wind on pressure levels',
    'source': file_in,
    'history': f'Created by script on {np.datetime64('now')}'
}

# Saving file
print('Saving file')
encoding = {
    'ua': {'dtype': 'float32', 'zlib': True, 'complevel': 4},
    'plev': {'dtype': 'float32'},
    'lat': {'dtype': 'float32'},
    'lon': {'dtype': 'float32'}
}

ds_out.to_netcdf(
    file_out, 
    engine='netcdf4', 
    format='NETCDF4_CLASSIC',
    encoding=encoding
)

# Final verification
print('Final verification')
ds_test = xr.open_dataset(file_out)
print(ds_test)
print('\nDimentions and coords:')
for dim in ds_test.dims:
    print(f'{dim}: {ds_test.dims[dim]}')


