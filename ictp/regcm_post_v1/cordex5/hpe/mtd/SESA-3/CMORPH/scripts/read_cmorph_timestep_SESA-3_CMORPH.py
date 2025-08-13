from __future__ import print_function

from netCDF4 import Dataset
from netCDF4 import num2date
import numpy as np
import datetime as dt
import os
import sys
import math

###########################################

   ##
   ##  input file specified on the command line
   ##  load the data into the numpy array
   ##

if len(sys.argv) == 3:
  # Read the input file as the first argument
  input_file = os.path.expandvars(sys.argv[1])
  time_index = int(sys.argv[2])
  try:
    # Print some output to verify that this script ran
    print("Input File: " + repr(input_file))
    print("Time Index: " + repr(time_index))

    # Read input file
    f = Dataset(input_file, 'r')

    # Read the requested variable
    var  = f.variables['cmorph']
    data = np.float64(f.variables['cmorph'][time_index,:,:])

    # Reset any negative values to missing data (-9999 in MET)
    data[data<0] = -9999

    # Flip data bottom to top
    data = data[::-1]

    # Extract the requested timestep and store a deep copy for MET
    met_data = data.copy()

    print("Data Shape: " + repr(met_data.shape))
    print("Data Type:  " + repr(met_data.dtype))
  except NameError:
    print("Trouble reading input file: " . input_file)
else:
    print("Must specify exactly one input file and the time index.")
    sys.exit(1)

###########################################

# Function to parse time strings with or without microseconds
def parse_dtg(time_str):
   try:
      time_val = dt.datetime.strptime(time_str, "%Y-%m-%d %H:%M:%S.%fZ")
   except:
      time_val = dt.datetime.strptime(time_str, "%Y-%m-%d %H:%M:%SZ")
   return time_val

###########################################

# Read the time variable
times      = f.variables['time']
valid_time = num2date(times[time_index], times.units, times.calendar)
init_time  = valid_time
accum_time = "000000"

print("Valid Time =", valid_time)
print("Accum Time =", accum_time)

# Determine LatLon grid information
lat = np.float64(f.variables['lat'][:])
lon = np.float64(f.variables['lon'][:])

###########################################

   ##
   ##  create the metadata dictionary
   ##

attrs = {
   'valid': valid_time.strftime("%Y%m%d_%H%M%S"),
   'init':  valid_time.strftime("%Y%m%d_%H%M%S"),
   'lead':  '00',
   'accum': accum_time,

   'name':      'cmorph',
   'long_name': 'accumulated precipitaiton',
   'level':     'Surface',
   'units':     'mm/hr',

   'grid': {
       'name' : 'SESA-3',
       'type' : 'LatLon',
       'lat_ll' : -35.25,
       'lon_ll' : -60.25,
       'delta_lon' : 0.0275,
       'delta_lat' : 0.0275,
       'Nlon' : 364,
       'Nlat' : 473,
   }
}

print("Attributes: " + repr(attrs))
