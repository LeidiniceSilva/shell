#!/usr/bin/env python
from dateutil import rrule
import datetime
import glob
from netCDF4 import Dataset
import sys, traceback
import dateutil.parser as dparser
import string
from pdb import set_trace as stop
import numpy as np
import numpy.ma as ma
import os
# from mpl_toolkits import basemap
import pickle
import subprocess
import pandas as pd
from scipy import stats
import copy
import matplotlib.pyplot as plt
import matplotlib.colors as colors
import matplotlib as mpl
import pylab as plt
import random
import scipy.ndimage as ndimage
import scipy
import shapefile
import matplotlib.path as mplPath
from matplotlib.patches import Polygon as Polygon2
# Cluster specific modules
from scipy.cluster.hierarchy import dendrogram, linkage
from scipy.cluster.hierarchy import cophenet
from scipy.spatial.distance import pdist
from scipy.cluster.hierarchy import fcluster
from scipy.cluster.vq import kmeans2,vq, whiten
from scipy.ndimage import gaussian_filter
#import seaborn as sns
# import metpy.calc as mpcalc
import shapefile as shp
import sys
from calendar import monthrange
#import h5py


dStartDayPR=datetime.datetime(2000, 1, 1,0) # (2000, 11, 01,0)
dStopDayPR=datetime.datetime(2000, 12, 31,23,59)
rgdTime = pd.date_range(dStartDayPR, end=dStopDayPR, freq='h')

TargetDir='/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/GPM/GPM_MERGIR'

for fi in range(len(rgdTime)):
    YYYY = str(rgdTime[fi].year)
    MM = str(rgdTime[fi].month).zfill(2)
    DD = str(rgdTime[fi].day).zfill(2)
    HH = str(rgdTime[fi].hour).zfill(2)
    day_of_year = (rgdTime[fi] - datetime.datetime(rgdTime[fi].year, 1, 1)).days + 1
    FileName = 'merg_'+YYYY+MM+DD+HH+'_4km-pixel.nc4'
    FILEact = 'https://disc2.gesdisc.eosdis.nasa.gov/data/MERGED_IR/GPM_MERGIR.1/'+YYYY+'/'+str(day_of_year).zfill(3)+'/'+FileName

    if not os.path.exists(TargetDir+'/'+str(YYYY)):
        os.makedirs(TargetDir+'/'+str(YYYY))
    
    if os.path.isfile(TargetDir+str(YYYY)+'/'+FileName) == False:
        pp = subprocess.Popen("wget --user=andreasprein --password=TheRising2002! --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --auth-no-challenge=on --keep-session-cookies --content-disposition "+FILEact, shell=True)
        pp.wait()
        
        pp = subprocess.Popen("mv "+FileName+' '+TargetDir+'/'+str(YYYY)+'/'+FileName, shell=True)
        pp.wait()
    
