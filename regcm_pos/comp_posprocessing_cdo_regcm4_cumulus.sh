#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '09/16/2021'
#__description__ = 'Posprocessing the RegCM4.7.1 model data with CDO'
 
echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

EXP="historical"
DATA="1986-2005"
DIR="/vol1/nice/exp_reg2/historical/output"

echo
cd ${DIR}
echo ${DIR}

echo 
echo "1. Select variable"

for YEAR in `seq -w 1986 2005`; do
    for MON in `seq -w 01 12`; do

        /usr/local/bin/cdo selname,pr reg_amz_neb_${EXP}_STS.${YEAR}${MON}0100.nc pr_flux_reg_had_${EXP}_${YEAR}${MON}0100.nc
        /usr/local/bin/cdo selname,tas reg_amz_neb_${EXP}_STS.${YEAR}${MON}0100.nc tas_kelv_reg_had_${EXP}_${YEAR}${MON}0100.nc
        /usr/local/bin/cdo selname,psl reg_amz_neb_${EXP}_SRF.${YEAR}${MON}0100.nc psl_pres_reg_had_${EXP}_${YEAR}${MON}0100.nc
        /usr/local/bin/cdo selname,hus reg_amz_neb_${EXP}_ATM.${YEAR}${MON}0100.nc hus_atm_reg_had_${EXP}_${YEAR}${MON}0100.nc
        /usr/local/bin/cdo selname,ua reg_amz_neb_${EXP}_ATM.${YEAR}${MON}0100.nc ua_atm_reg_had_${EXP}_${YEAR}${MON}0100.nc
        /usr/local/bin/cdo selname,va reg_amz_neb_${EXP}_ATM.${YEAR}${MON}0100.nc va_atm_reg_had_${EXP}_${YEAR}${MON}0100.nc


    done
done	

echo 
echo "2. Concatenate data"

/usr/local/bin/cdo cat pr_flux_reg_had_${EXP}_*0100.nc pr_flux_reg_had_${EXP}_${DATA}.nc
/usr/local/bin/cdo cat tas_kelv_reg_had_${EXP}_*0100.nc tas_kelv_reg_had_${EXP}_${DATA}.nc
/usr/local/bin/cdo cat psl_pres_reg_had_${EXP}_*0100.nc psl_pres_reg_had_${EXP}_${DATA}.nc
/usr/local/bin/cdo cat hus_atm_reg_had_${EXP}_*0100.nc hus_atm_reg_had_${EXP}_${DATA}.nc
/usr/local/bin/cdo cat ua_atm_reg_had_${EXP}_*0100.nc ua_atm_reg_had_${EXP}_${DATA}.nc
/usr/local/bin/cdo cat va_atm_reg_had_${EXP}_*0100.nc va_atm_reg_had_${EXP}_${DATA}.nc

echo
echo "3. Convert calendar: standard"

/usr/local/bin/cdo setcalendar,standard pr_flux_reg_had_${EXP}_${DATA}.nc pr_amz_neb_reg_had_${EXP}_${DATA}_stand.nc
/usr/local/bin/cdo setcalendar,standard tas_kelv_reg_had_${EXP}_${DATA}.nc tas_amz_neb_reg_had_${EXP}_${DATA}_stand.nc
/usr/local/bin/cdo setcalendar,standard psl_pres_reg_had_${EXP}_${DATA}.nc psl_pres_reg_had_${EXP}_${DATA}_stand.nc
/usr/local/bin/cdo setcalendar,standard hus_atm_reg_had_${EXP}_${DATA}.nc hus_atm_reg_had_${EXP}_${DATA}_stand.nc
/usr/local/bin/cdo setcalendar,standard ua_atm_reg_had_${EXP}_${DATA}.nc ua_atm_reg_had_${EXP}_${DATA}_stand.nc
/usr/local/bin/cdo setcalendar,standard va_atm_reg_had_${EXP}_${DATA}.nc va_atm_reg_had_${EXP}_${DATA}_stand.nc

echo 
echo "4. Unit convention"

/usr/local/bin/cdo mulc,86400 pr_amz_neb_reg_had_${EXP}_${DATA}_stand.nc pr_amz_neb_reg_had_${EXP}_${DATA}.nc
/usr/local/bin/cdo addc,-273.15 tas_amz_neb_reg_had_${EXP}_${DATA}_stand.nc tas_amz_neb_reg_had_${EXP}_${DATA}.nc
/usr/local/bin/cdo divc,100 psl_pres_reg_had_${EXP}_${DATA}_stand.nc psl_amz_neb_reg_had_${EXP}_${DATA}.nc

echo
echo "5. Month mean"

/usr/local/bin/cdo monmean pr_amz_neb_reg_had_${EXP}_${DATA}.nc pr_amz_neb_RegCM4_HadG_${EXP}_mon_${DATA}.nc
/usr/local/bin/cdo monmean tas_amz_neb_reg_had_${EXP}_${DATA}.nc tas_amz_neb_RegCM4_HadG_${EXP}_mon_${DATA}.nc
/usr/local/bin/cdo monmean psl_amz_neb_reg_had_${EXP}_${DATA}.nc tas_amz_neb_RegCM4_HadG_${EXP}_mon_${DATA}.nc
/usr/local/bin/cdo monmean hus_atm_reg_had_${EXP}_${DATA}_stand.nc hus_amz_neb_RegCM4_HadG_${EXP}_mon_${DATA}.nc
/usr/local/bin/cdo monmean ua_atm_reg_had_${EXP}_${DATA}_stand.nc ua_amz_neb_RegCM4_HadG_${EXP}_mon_${DATA}.nc
/usr/local/bin/cdo monmean va_atm_reg_had_${EXP}_${DATA}_stand.nc va_amz_neb_RegCM4_HadG_${EXP}_mon_${DATA}.nc

echo 
echo "6. Deleting file"

rm pr_flux_*.nc
rm tas_kelv_*.nc
rm psl_pres_*.nc
rm hua_atm_*.nc
rm ua_atm_*.nc
rm va_atm_*.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

