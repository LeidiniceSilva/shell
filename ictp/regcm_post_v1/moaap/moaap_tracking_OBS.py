# -*- coding: utf-8 -*-

__author__      = "Leidinice Silva"
__email__       = "leidinicesilva@gmail.com"
__date__        = "March 03, 2026"
__description__ = "This script track MCSs"

import glob
import argparse
import xarray as xr
import netCDF4
import cartopy
import numpy as np
import pandas as pd
import metpy
import warnings
warnings.filterwarnings("ignore")

from tqdm import tqdm
from Tracking_Functions import moaap

parser = argparse.ArgumentParser()
parser.add_argument('--domain', required=True, help='Domain')
args = parser.parse_args()

domain=args.domain
path='/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/ERA5'

files = sorted(glob.glob(f'{path}/{domain}/input/{domain}_ERA5_reanalysis_1hr_*.nc'))
for f in files:
    print(f)

    data_vars = xr.open_dataset(f)
    lon = data_vars['longitude']
    lat = data_vars['latitude']

    lon2d, lat2d = np.meshgrid(lon, lat)
    Mask = np.copy(lon2d); Mask[:]=1

    time_datetime = pd.to_datetime(np.array(data_vars['time'].values, dtype='datetime64'))
    dT = 1 

    DataName = 'ERA5_evaluation'
    OutputFolder = f'{path}/{domain}/output/'

    object_split = moaap(
                      lon2d,
                      lat2d,
                      time_datetime,
                      dT,
                      Mask,
                      v850 = None,
                      u850 = None,
                      t850 = None,
                      q850 = None,
                      slp  = None,
                      ivte = None,
                      ivtn = None,
                      z500 = None,
                      v200 = None,
                      u200 = None,
                      pr   = np.array(data_vars['tp']),
                      tb   = np.array(data_vars['Tb']),
                      DataName = DataName,
                      OutputFolder = OutputFolder,
                      js_min_anomaly = 12,
                      MinTimeJS = 12,
                        )









