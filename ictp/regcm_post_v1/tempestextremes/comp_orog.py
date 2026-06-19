# -*- coding: utf-8 -*-

__author__      = "Leidinice Silva"
__email__       = "leidinicesilva@gmail.com"
__date__        = "March 17, 2026"
__description__ = "This script compute orography"

import xarray as xr
import numpy as np

# Input file
infile = "/leonardo/home/userexternal/mdasilva/leonardo_work/TempestExtremes/ERA5/z_era5.nc"
outfile = "/leonardo/home/userexternal/mdasilva/leonardo_work/TempestExtremes/input/orog_era5.nc"

# Read data
ds = xr.open_dataset(infile)

# Convert geopotential (m2 s-2) to height (m)
g = 9.80665
oro = ds["z"] / g

# Remove negative values
oro = oro.where(oro >= 0, 0)

# Create output dataset
ds_out = xr.Dataset(
    data_vars={
        "orog": (
            ("time", "latitude", "longitude"),
            oro.values
        )
    },
    coords={
        "time": ds.time,
        "latitude": ds.latitude,
        "longitude": ds.longitude
    }
)

# Attributes
ds_out["orog"].attrs = {
    "long_name": "Surface orography",
    "standard_name": "surface_altitude",
    "units": "m"
}

# Save
encoding = {
    "orog": {
        "_FillValue": -9999.0,
        "zlib": True,
        "complevel": 4
    }
}

ds_out.to_netcdf(outfile, encoding=encoding)

print(f"Saved: {outfile}")
print(f"Min elevation: {float(ds_out.orog.min()):.2f} m")
print(f"Max elevation: {float(ds_out.orog.max()):.2f} m")
