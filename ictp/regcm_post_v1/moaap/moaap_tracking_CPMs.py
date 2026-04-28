# -*- coding: utf-8 -*-

__author__      = "Leidinice Silva"
__email__       = "leidinicesilva@gmail.com"
__date__        = "March 03, 2026"
__description__ = "This script track MCSs"

import glob
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

domain='CSAM-3'
exp = 'ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1'
path='/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/CPMs'.format(domain)

files = sorted(glob.glob(f'{path}/{domain}/input/{domain}_ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1_1hr_20000101.nc'))
for f in files:
    print(f)

    data_vars = xr.open_dataset(f)
    lon = np.array(data_vars['lon'])
    lat = np.array(data_vars['lat'])
    lon = lon[:, :-1]
    lat = lat[:, :-1]

    Mask = np.copy(lon); Mask[:]=1

    time_datetime = pd.to_datetime(np.array(data_vars['time'].values, dtype='datetime64'))
    dT = 1 

    print(lon.shape)
    print(lat.shape)

    DataName = 'RegCM5_ERA5'
    OutputFolder = f'{path}/{domain}/output/'

    object_split = moaap(
                      lon,
                      lat,
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
                      pr   = np.array(data_vars['pr']),
                      tb   = np.array(data_vars['Tb']),
                      DataName = DataName,
                      OutputFolder = OutputFolder,
                      js_min_anomaly = 12,
                      MinTimeJS = 12,
                        )









