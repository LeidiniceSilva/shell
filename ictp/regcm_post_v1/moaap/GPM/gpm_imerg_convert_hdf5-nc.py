#!/usr/bin/env python

__author__      = "Leidinice Silva"
__email__       = "leidinicesilva@gmail.com"
__date__        = "May 25, 2026"
__description__ = "This script convert GPM IMERG"

import os
import glob
import xarray as xr

year=2000
base_path = f"/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/GPM/globe/GPM_IMERG/{year}"

def process_file(hdf_path):
    nc_path = hdf_path.rsplit(".", 1)[0] + ".nc"

    # Skip if output NetCDF already exists and is not empty
    if os.path.exists(nc_path) and os.path.getsize(nc_path) > 0:
        return

    try:
        ds = xr.open_dataset(hdf_path, group="Grid", engine="netcdf4")

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
        ds.to_netcdf(nc_path)
        ds.close()
        print(f"Converted: {nc_path}")

    except Exception as e:
        print(f"Failed processing {hdf_path}: {e}")

# Find all HDF5 files recursively
for root, _, files in os.walk(base_path):
    for f in files:
        if f.endswith(".HDF5") or f.endswith(".hdf5"):
            full_path = os.path.join(root, f)
            process_file(full_path)

print("Done")
