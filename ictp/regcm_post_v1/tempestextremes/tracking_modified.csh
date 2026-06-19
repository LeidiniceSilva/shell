#!/bin/csh

set dir	= /leonardo/home/userexternal/mdasilva/leonardo_work/TempestExtremes/

# input
set inFile_slp = ${dir}input/msl_era5_6hr_1-5Jan2020_chname.nc
set inFile_u10 = ${dir}input/u10_era5_6hr_1-5Jan2020_chname.nc
set inFile_v10 = ${dir}input/v10_era5_6hr_1-5Jan2020_chname.nc
set inFile_z3  = ${dir}input/z300_era5_6hr_1-5Jan2020_chname.nc
set inFile_z5  = ${dir}input/z500_era5_6hr_1-5Jan2020_chname.nc
set inFile_oro = ${dir}input/orog_era5_6hr_1-5Jan2020.nc

# output
set Detect = ${dir}output/Detect_1-5Jan2020.dat
set Stitch = ${dir}output/Stitch_1-5Jan2020.dat

/leonardo/home/userexternal/mdasilva/tempestextremes/bin/DetectNodes \
--in_data "$inFile_slp;$inFile_u10;$inFile_v10;$inFile_z3;$inFile_z5;$inFile_oro" \
--out "$Detect" \
--searchbymin msl \
--closedcontourcmd "msl,200.0,5.5,0;_DIFF(z300,z500),-58.8,6.5,1.0" \
--latname "latitude" --lonname "longitude" \
--mergedist 6.0 \
--regional \
--outputcmd "msl,min,0;_VECMAG(u10,v10),max,2;orog,min,0"

/leonardo/home/userexternal/mdasilva/tempestextremes/bin/StitchNodes \
--in "$Detect" --out "$Stitch" \
--in_fmt "lon,lat,slp,wind,z" \
--mintime "54h" --maxgap "24h" --range 6.0 \
--threshold "wind,>=,10.0,10;lon,<=,180.0,10;lon,>=,100.0,10;lat,<=,50.0,10;lat,>=,0.0,10;z,<=,150.0,10"

exit
