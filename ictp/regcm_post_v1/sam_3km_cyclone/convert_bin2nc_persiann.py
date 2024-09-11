#!/usr/bin/env python3

import sys
import gzip
from datetime import datetime, date
import numpy as np
from netCDF4 import Dataset

filename = sys.argv[1]

try:
    if isinstance(filename, str) and filename.endswith(".gz"):
        with gzip.open(filename, 'rb') as f:
            datain = np.frombuffer(f.read(), dtype='>i2',
                                   count=-1, offset=0).reshape((1,3000,9000))
    else:
        datain = np.fromfile(filename, dtype='>i2',
                             count=-1, offset=0).reshape((1,3000,9000))
except:
    print("Cannot open file: ",filename)
    sys.exit(-1)

filetime = filename[7:14]
year = "20"+filetime[0:2]
day_num = filetime[2:5]
hour = filetime[5:7]
time = datetime.strptime(year+"-"+day_num+" "+hour,"%Y-%j %H")
reference_time = datetime.fromisoformat("2000-01-01")

lon = np.linspace(0.02,360-0.02,num=9000)
lat = np.linspace(59.98,-60+0.02,num=3000)

ncfile = Dataset(filename[0:14]+".nc", "w", format="NETCDF4")
ncfile.title = "PERSIANN-Cloud Classification System (PERSIANN-CCS) product"
ncfile.institution = "Center for Hydrometeorology and Remote Sensing (CHRS) at the University of California, Irvine (UCI)"
today = date.today()
ncfile.history = "Converted into NetCDF in ICTP on "+today.strftime("%Y-%m-%d")
ncfile.conventions = "CF-1.8"

dtime = ncfile.createDimension("time", None)
dbnd = ncfile.createDimension("bounds", 2)
dlat = ncfile.createDimension("lat", lat.size)
dlon = ncfile.createDimension("lon", lon.size)

vtime = ncfile.createVariable("time","f4",("time",))
vtime.standard_name = "time"
vtime.long_name = "Time"
vtime.units = "hours since 2000-01-01 00:00:00"
vtime.bounds = "bounds"
vbnd = ncfile.createVariable("bounds","f4",("time","bounds",))
vbnd.standard_name = "time"
vbnd.long_name = "time interval endpoints"
vlon = ncfile.createVariable("lon","f4",("lon",))
vlon.long_name = "Longitude"
vlon.standard_name = "longitude"
vlon.units = "degrees_east"
vlat = ncfile.createVariable("lat","f4",("lat",))
vlat.long_name = "Latitude"
vlat.standard_name = "latitude"
vlat.units = "degrees_north"
vpre = ncfile.createVariable("prec","i2",("time","lat","lon",),
                             zlib=True,fill_value=-9999.0)
vpre.set_auto_scale(False)
vpre.long_name = "Satellite precipitation product"
vpre.standard_name = "precipitation"
vpre.scale_factor = 0.01
vpre.units = "mm/hr"

vlat[:] = lat
vlon[:] = lon
td = time-reference_time
days, hours = td.days, td.seconds // 3600
thdiff = td.days * 24 + hours
vtime[:] = thdiff
vbnd[:,0] = thdiff-1
vbnd[:,1] = thdiff
vpre[:] = datain
ncfile.close( )
