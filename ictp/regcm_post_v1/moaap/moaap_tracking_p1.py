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

path='/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP'

domain='EURR-3'
exp = 'ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1'

files = sorted(glob.glob(f'{path}/{domain}/input/*.nc'))
for f in files:
    print(f)

    data_vars = xr.open_dataset(f)
    lon = np.array(data_vars['lon'])
    lat = np.array(data_vars['lat'])
    lon = lon[:, :-1]
    lat = lat[:, :-1]
    print(data_vars)

    dT = 1 # input time interval (hr)
    Mask = np.copy(data_vars['lon']); Mask[:]=1 # tracking is applied globally
    time_datetime = pd.to_datetime(np.array(data_vars['time'].values, dtype='datetime64'))

    DataName = 'RegCM5_ERA5_evaluation'
    OutputFolder = f'{path}/{domain}/output/'

    object_split = moaap(
                      lon,
                      lat,
                      time_datetime,
                      dT,
                      Mask[:, :-1],
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
                      pr   = np.array(data_vars['pr'])[:, :, :-1],
                      tb   = np.array(data_vars['Tb'])[:, :, :-1],
                      DataName = DataName,
                      OutputFolder = OutputFolder,
                      js_min_anomaly = 12,
                      MinTimeJS = 12,
                        )









