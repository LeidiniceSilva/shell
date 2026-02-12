#!/usr/bin/env python3

import os
import cdsapi
import calendar

client = cdsapi.Client()

dataset = "derived-era5-pressure-levels-daily-statistics"

# Period
years = range(2018, 2022)  

# Pressure levels
pressure_levels = [
    "1","2","3","5","7","10",
    "20","30","50","70","100","125",
    "150","175","200","225","250","300",
    "350","400","450","500","550","600",
    "650","700","750","775","800","825",
    "850","875","900","925","950","975","1000"
]

# Output directory
outdir = "daily"
os.makedirs(outdir, exist_ok=True)

for year in years:
    yy = f"{year:04d}"

    for month in range(1, 13):
        mm = f"{month:02d}"

        # Get valid days for the month
        ndays = calendar.monthrange(year, month)[1]

        for day in range(1, ndays + 1):
            dd = f"{day:02d}"

            outfile = os.path.join(
                outdir,
                f"w_ERA5_day_{yy}{mm}{dd}.nc"
            )

            if os.path.isfile(outfile):
                print(f"{outfile} exists – skipping")
                continue

            print(f"Downloading {yy}-{mm}-{dd}")

            request = {
                "product_type": "reanalysis",
                "variable": ["vertical_velocity"], 
                "year": yy,
                "month": mm,
                "day": dd,
                "pressure_level": pressure_levels,
                "daily_statistic": "daily_mean",
                "time_zone": "utc+00:00",
                "frequency": "1_hourly",
                "format": "netcdf"
            }

            client.retrieve(dataset, request, outfile)

