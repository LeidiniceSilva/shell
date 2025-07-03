#!/usr/bin/python3

import sys
from netCDF4 import Dataset

ds = Dataset(sys.argv[1],'r+')
ds.variables['mcdate'][0] = 19700101
ds.close( )
