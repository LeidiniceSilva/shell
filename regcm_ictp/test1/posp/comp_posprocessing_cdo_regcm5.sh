#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '10/02/2023'
#__description__ = 'Posprocessing the RegCM5 model data with CDO'
 

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

NAME="SAM-22"
DIR="/home/mda_silv/scratch/test1/output"

echo
cd ${DIR}
echo ${DIR}

echo 
echo "1. Select variable"

for MON in `seq -w 01 12`; do

    #echo "Data: ${MON}/2000"
    #cdo selname,pr ${NAME}_STS.2000${MON}0100.nc pr_${NAME}_2000${MON}0100.nc
    #cdo selname,tas ${NAME}_STS.2000${MON}0100.nc tas_${NAME}_2000${MON}0100.nc
    cdo selname,cl ${NAME}_.2000${MON}0100.nc cl_${NAME}_2000${MON}0100.nc
    cdo selname,o3 ${NAME}_RAD.2000${MON}0100.nc o3_${NAME}_2000${MON}0100.nc
    cdo selname,rtnscl ${NAME}_RAD.2000${MON}0100.nc rtnscl_${NAME}_2000${MON}0100.nc
    cdo selname,rsnscl ${NAME}_RAD.2000${MON}0100.nc rsnscl_${NAME}_2000${MON}0100.nc
    cdo selname,tauci ${NAME}_RAD.2000${MON}0100.nc tauci_${NAME}_2000${MON}0100.nc

done	

echo 
echo "2. Concatenate data"

#cdo cat pr_${NAME}_2000*0100.nc pr_${NAME}_2000.nc 
#cdo cat tas_${NAME}_2000*0100.nc tas_${NAME}_2000.nc 
cdo cat cl_${NAME}_2000*0100.nc cl_${NAME}_2000.nc 
cdo cat o3_${NAME}_2000*0100.nc o3_${NAME}_2000.nc 
cdo cat rtnscl_${NAME}_2000*0100.nc rtnscl_${NAME}_2000.nc 
cdo cat rsnscl_${NAME}_2000*0100.nc rsnscl_${NAME}_2000.nc 
cdo cat tauci_${NAME}_2000*0100.nc tauci_${NAME}_2000.nc 

echo
echo "3. Convert calendar: standard"

#cdo setcalendar,standard pr_${NAME}_2000.nc pr_${NAME}_day_2000.nc
#cdo setcalendar,standard tas_${NAME}_2000.nc tas_${NAME}_day_2000.nc
cdo setcalendar,standard cl_${NAME}_2000.nc tas_${NAME}_day_2000.nc
cdo setcalendar,standard o3_${NAME}_2000.nc tas_${NAME}_day_2000.nc
cdo setcalendar,standard rtnscl_${NAME}_2000.nc rtnscl_${NAME}_day_2000.nc
cdo setcalendar,standard rsnscl_${NAME}_2000.nc rsnscl_${NAME}_day_2000.nc
cdo setcalendar,standard tauci_${NAME}_2000.nc tauci_${NAME}_day_2000.nc

echo 
echo "4. Remapbil (Precipitation and Temperature 2m: South America)"

#/home/mda_silv/github_projects/shell/regcm_pos/./regrid pr_${NAME}_day_2000.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil
#/home/mda_silv/github_projects/shell/regcm_pos/./regrid tas_${NAME}_day_2000.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil 
/home/mda_silv/github_projects/shell/regcm_pos/./regrid cl_${NAME}_day_2000.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil 
/home/mda_silv/github_projects/shell/regcm_pos/./regrid o3_${NAME}_day_2000.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil 
/home/mda_silv/github_projects/shell/regcm_pos/./regrid rtnscl_${NAME}_day_2000.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil 
/home/mda_silv/github_projects/shell/regcm_pos/./regrid rsnscl_${NAME}_day_2000.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil 
/home/mda_silv/github_projects/shell/regcm_pos/./regrid tauci_${NAME}_day_2000.nc -57.89861,18.49594,0.22 -105.8313,-16.58986,0.22 bil 

echo 
echo "5. Unit convention (mm/d and celsius)"

#cdo mulc,86400 pr_${NAME}_day_2000_lonlat.nc pr_${NAME}_Reg5_day_2000_lonlat.nc
#cdo addc,-273.15 tas_${NAME}_day_2000_lonlat.nc tas_${NAME}_Reg5_day_2000_lonlat.nc
cp cl_${NAME}_day_2000_lonlat.nc cl_${NAME}_Reg5_day_2000_lonlat.nc 
cp o3_${NAME}_day_2000_lonlat.nc o3_${NAME}_Reg5_day_2000_lonlat.nc 
cp rtnscl_${NAME}_day_2000_lonlat.nc rtnscl_${NAME}_Reg5_day_2000_lonlat.nc 
cp rsnscl_${NAME}_day_2000_lonlat.nc rsnscl_${NAME}_Reg5_day_2000_lonlat.nc 
cp tauci_${NAME}_day_2000_lonlat.nc tauci_${NAME}_Reg5_day_2000_lonlat.nc 

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"
