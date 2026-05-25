#!/usr/bin/env python

__author__      = "Leidinice Silva"
__email__       = "leidinicesilva@gmail.com"
__date__        = "May 25, 2026"
__description__ = "This script convert GPM IMERG"

import xarray as xr

file = "3B-HHR.MS.MRG.3IMERG.20000601-S000000-E002959.0000.V07B.HDF5"

ds = xr.open_dataset(file, group="Grid", engine="netcdf4")

# Select precipitation only
ds = ds[["precipitation"]]
ds = ds.rename({"precipitation": "PR"})
ds = ds.transpose("time", "lat", "lon")
ds = ds.rename({"lat": "latitude", "lon": "longitude"})

# Add metadata 
ds["PR"].attrs = {
    "long_name": "Total precipitation",
    "units": "mm hr-1",
    "standard_name": "precipitation"
}

ds["latitude"].attrs = {
    "standard_name": "latitude",
    "units": "degrees_north",
    "axis": "Y"
}

ds["longitude"].attrs = {
    "standard_name": "longitude",
    "units": "degrees_east",
    "axis": "X"
}

ds["time"].attrs = {
    "standard_name": "time",
    "axis": "T"
}

ds.attrs = {
    "Conventions": "CF-1.6",
    "source": "NASA GPM IMERG V07B"
}

# Save NetCDF
ds.to_netcdf("3B-HHR.MS.MRG.3IMERG.20000601-S000000-E002959.0000.V07B.nc")

