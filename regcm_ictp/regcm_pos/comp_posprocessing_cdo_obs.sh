#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the CRU dataset with CDO'
 

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

DIR_IN="/home/esp-shared-a/Observations/CRU/CRU_TS4.07"
DIR_OUT="/afs/ictp.it/home/m/mda_silv/Documents/ICTP/database/obs/cru"
DIR_REGRID="/afs/ictp.it/home/m/mda_silv/Documents/github_projects/shell/regcm_ufrn/regcm_pos"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo 
echo "1. Select date"

cdo seldate,2018-01-01,2021-12-31 ${DIR_IN}/cru_ts4.07.1901.2022.cld.dat.nc cld_cru_ts4.07_mon_2018-2021.nc
cdo seldate,2018-01-01,2021-12-31 ${DIR_IN}/cru_ts4.07.1901.2022.pre.dat.nc pre_cru_ts4.07_mon_2018-2021.nc
cdo seldate,2018-01-01,2021-12-31 ${DIR_IN}/cru_ts4.07.1901.2022.tmp.dat.nc tmp_cru_ts4.07_mon_2018-2021.nc
cdo seldate,2018-01-01,2021-12-31 ${DIR_IN}/cru_ts4.07.1901.2022.tmx.dat.nc tmx_cru_ts4.07_mon_2018-2021.nc
cdo seldate,2018-01-01,2021-12-31 ${DIR_IN}/cru_ts4.07.1901.2022.tmn.dat.nc tmn_cru_ts4.07_mon_2018-2021.nc

echo 
echo "2. Regrid output"

${DIR_REGRID}/./regrid cld_cru_ts4.07_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${DIR_REGRID}/./regrid pre_cru_ts4.07_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${DIR_REGRID}/./regrid tmp_cru_ts4.07_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${DIR_REGRID}/./regrid tmx_cru_ts4.07_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
${DIR_REGRID}/./regrid tmn_cru_ts4.07_mon_2018-2021.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil

echo 
echo "3. Convert unit"

cdo divc,30.5 pre_cru_ts4.07_mon_2018-2021_lonlat.nc pre_SAM-3km_cru_ts4.07_mon_2018-2021_lonlat.nc

echo 
echo "4. Change files name"

cp cld_cru_ts4.07_mon_2018-2021_lonlat.nc cld_SAM-3km_cru_ts4.07_mon_2018-2021_lonlat.nc
cp tmp_cru_ts4.07_mon_2018-2021_lonlat.nc tmp_SAM-3km_cru_ts4.07_mon_2018-2021_lonlat.nc
cp tmx_cru_ts4.07_mon_2018-2021_lonlat.nc tmx_SAM-3km_cru_ts4.07_mon_2018-2021_lonlat.nc
cp tmn_cru_ts4.07_mon_2018-2021_lonlat.nc tmn_SAM-3km_cru_ts4.07_mon_2018-2021_lonlat.nc

echo 
echo "5. Delete files"

rm cld_cru_ts4.07_mon_2018-2021.nc
rm pre_cru_ts4.07_mon_2018-2021.nc
rm tmp_cru_ts4.07_mon_2018-2021.nc 
rm tmx_cru_ts4.07_mon_2018-2021.nc
rm tmn_cru_ts4.07_mon_2018-2021.nc
rm cld_cru_ts4.07_mon_2018-2021_lonlat.nc
rm pre_cru_ts4.07_mon_2018-2021_lonlat.nc
rm tmp_cru_ts4.07_mon_2018-2021_lonlat.nc 
rm tmx_cru_ts4.07_mon_2018-2021_lonlat.nc 
rm tmn_cru_ts4.07_mon_2018-2021_lonlat.nc 

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"
