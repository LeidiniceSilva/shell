#!/usr/bin/env python

__author__      = "Leidinice Silva"
__email__       = "leidinicesilva@gmail.com"
__date__        = "May 25, 2026"
__description__ = "This script download GPM MERGIR"

import os
import datetime
import subprocess
import pandas as pd

dStartDayPR=datetime.datetime(2002, 1, 1,0) # (2000, 11, 01,0)
dStopDayPR=datetime.datetime(2009, 12, 31,23,59)
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
    
