#!/bin0/bash

cdo remapbil,grid_AFR.txt land.nc mask_AFR.nc
cdo remapbil,grid_AUS.txt land.nc mask_AUS.nc
cdo remapbil,grid_CAM.txt land.nc mask_CAM.nc
cdo remapbil,grid_EAS.txt land.nc mask_EAS.nc
cdo remapbil,grid_EUR.txt land.nc mask_EUR.nc
cdo remapbil,grid_NAM.txt land.nc mask_NAM.nc
cdo remapbil,grid_SAM.txt land.nc mask_SAM.nc
cdo remapbil,grid_WAS.txt land.nc mask_WAS.nc
