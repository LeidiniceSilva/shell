#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '12/28/2020'
#__description__ = 'Posprocessing the RegCM4.7.1 model data with CDO'
 

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

EXP="rcp85"
DATA="2080-2099"
DIR="/home/nice/Documents/dataset/rcm/${EXP}"

echo
cd ${DIR}
echo ${DIR}

echo 
echo "1. Select variable (tasmin and tasmax)"

for YEAR in `seq -w 2080 2099`; do
    for MON in `seq -w 01 12`; do

        echo "Data: ${YEAR}${MON} - Variables: Precipitation"
        cdo selname,tasmin reg_${EXP}_STS.${YEAR}${MON}0100.nc tasmin_kelv_reg_had_${EXP}_${YEAR}${MON}0100.nc
        echo "Data: ${YEAR}${MON} - Variable: Temperature 2 m"
        cdo selname,tasmax reg_${EXP}_STS.${YEAR}${MON}0100.nc tasmax_kelv_reg_had_${EXP}_${YEAR}${MON}0100.nc

    done
done	

echo 
echo "2. Concatenate data"

echo "Data: ${DATA} - Variables: Precipitation"
cdo cat tasmin_kelv_reg_had_${EXP}_*0100.nc tasmin_kelv_reg_had_${EXP}_${DATA}.nc
echo "Data: ${DATA} - Variable: Temperature 2 m"
cdo cat tasmax_kelv_reg_had_${EXP}_*0100.nc tasmax_kelv_reg_had_${EXP}_${DATA}.nc

echo
echo "3. Convert calendar: standard"

echo "Data: ${DATA} - Variables: Precipitation"
cdo setcalendar,standard tasmin_kelv_reg_had_${EXP}_${DATA}.nc tasmin_amz_neb_reg_had_${EXP}_${DATA}.nc
echo "Data: ${DATA} - Variable: Temperature 2 m"
cdo setcalendar,standard tasmax_kelv_reg_had_${EXP}_${DATA}.nc tasmax_amz_neb_reg_had_${EXP}_${DATA}.nc

#echo 
#echo "4. Unit convention (mm/d and celsius)"

#echo "Data: ${DATA} - Variables: Precipitation"
#cdo addc,-273.15 tasmin_kelv_reg_had_${EXP}_${DATA}_stand.nc tasmin_amz_neb_reg_had_${EXP}_${DATA}.nc
#echo "Data: ${DATA} - Variable: Temperature 2 m"
#cdo addc,-273.15 tasmax_kelv_reg_had_${EXP}_${DATA}_stand.nc tasmax_amz_neb_reg_had_${EXP}_${DATA}.nc

echo 
echo "5. Remapbil (Precipitation and Temperature 2m: AMZ_NEB)"

echo "Data: ${DATA} - Variables: Precipitation"
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid tasmin_amz_neb_reg_had_${EXP}_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil
echo "Data: ${DATA} - Variable: Temperature 2 m"
/home/nice/Documents/github_projects/shell/regcm_pos/./regrid tasmax_amz_neb_reg_had_${EXP}_${DATA}.nc -20,10,0.25 -85,-15,0.25 bil 

echo
echo "6. Creating sea mask"

echo "Data: ${DATA} - Variables: Precipitation"
cdo -f nc -remapnn,tasmin_amz_neb_reg_had_${EXP}_${DATA}_lonlat.nc -gtc,0 -topo tasmin_seamask.nc
cdo ifthen tasmin_seamask.nc tasmin_amz_neb_reg_had_${EXP}_${DATA}_lonlat.nc tasmin_amz_neb_reg_had_${EXP}_${DATA}_lonlat_seamask.nc
echo "Data: ${DATA} - Variables: Temperature 2 m"
cdo -f nc -remapnn,tasmax_amz_neb_reg_had_${EXP}_${DATA}_lonlat.nc -gtc,0 -topo tasmax_seamask.nc
cdo ifthen tasmax_seamask.nc tasmax_amz_neb_reg_had_${EXP}_${DATA}_lonlat.nc tasmax_amz_neb_reg_had_${EXP}_${DATA}_lonlat_seamask.nc

#echo
#echo "7. Select new area: amz (-68,-52,-12,-3), neb (-40,-35,-16,-3) and matopiba (-50.5,-42.5,-15,-2.5)"

#echo "Data: ${DATA} - Variables: Precipitation"
#cdo sellonlatbox,-68,-52,-12,-3 pr_amz_neb_reg_had_${EXP}_${DATA}_lonlat_seamask.nc pr_samz_reg_had_${EXP}_${DATA}_lonlat_seamask.nc
#cdo sellonlatbox,-40,-35,-16,-3 pr_amz_neb_reg_had_${EXP}_${DATA}_lonlat_seamask.nc pr_eneb_reg_had_${EXP}_${DATA}_lonlat_seamask.nc
#cdo sellonlatbox,-50.5,-42.5,-15,-2.5 pr_amz_neb_reg_had_${EXP}_${DATA}_lonlat_seamask.nc pr_matopiba_reg_had_${EXP}_${DATA}_lonlat_seamask.nc
#echo "Data: ${DATA} - Variables: Temperature 2 m"
#cdo sellonlatbox,-68,-52,-12,-3 tas_amz_neb_reg_had_${EXP}_${DATA}_lonlat_seamask.nc tas_samz_reg_had_${EXP}_${DATA}_lonlat_seamask.nc
#cdo sellonlatbox,-40,-35,-16,-3 tas_amz_neb_reg_had_${EXP}_${DATA}_lonlat_seamask.nc tas_eneb_reg_had_${EXP}_${DATA}_lonlat_seamask.nc
#cdo sellonlatbox,-50.5,-42.5,-15,-2.5 tas_amz_neb_reg_had_${EXP}_${DATA}_lonlat_seamask.nc tas_matopiba_reg_had_${EXP}_${DATA}_lonlat_seamask.nc

#echo
#echo "8. Month mean (mm/d and celsius)"

#cdo monmean pr_amz_neb_reg_had_${EXP}_${DATA}_lonlat_seamask.nc pr_amz_neb_reg_had_${EXP}_mon_${DATA}_lonlat_seamask.nc
#cdo monmean pr_samz_reg_had_${EXP}_${DATA}_lonlat_seamask.nc pr_samz_reg_had_${EXP}_mon_${DATA}_lonlat_seamask.nc
#cdo monmean pr_eneb_reg_had_${EXP}_${DATA}_lonlat_seamask.nc pr_eneb_reg_had_${EXP}_mon_${DATA}_lonlat_seamask.nc
#cdo monmean pr_matopiba_reg_had_${EXP}_${DATA}_lonlat_seamask.nc pr_matopiba_reg_had_${EXP}_mon_${DATA}_lonlat_seamask.nc

#cdo monmean tas_amz_neb_reg_had_${EXP}_${DATA}_lonlat_seamask.nc tas_amz_neb_reg_had_${EXP}_mon_${DATA}_lonlat_seamask.nc
#cdo monmean tas_samz_reg_had_${EXP}_${DATA}_lonlat_seamask.nc tas_samz_reg_had_${EXP}_mon_${DATA}_lonlat_seamask.nc
#cdo monmean tas_eneb_reg_had_${EXP}_${DATA}_lonlat_seamask.nc tas_eneb_reg_had_${EXP}_mon_${DATA}_lonlat_seamask.nc
#cdo monmean tas_matopiba_reg_had_${EXP}_${DATA}_lonlat_seamask.nc tas_matopiba_reg_had_${EXP}_mon_${DATA}_lonlat_seamask.nc

echo 
echo "9. Deleting file"

rm *STS*
rm tasmin_kelv_*.nc
rm tasmin_amz_neb_reg_had_${EXP}_${DATA}.nc
rm tasmin_amz_neb_reg_had_${EXP}_${DATA}_lonlat.nc
rm tasmin_seamask.nc
rm tasmax_kelv_*.nc
rm tasmax_amz_neb_reg_had_${EXP}_${DATA}.nc
rm tasmax_amz_neb_reg_had_${EXP}_${DATA}_lonlat.nc
rm tasmax_seamask.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

