#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jan 02, 2024'
#__description__ = 'Posprocessing the RegCM5 output with CDO'

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

YEAR="2023"
DATE="20230101-20231231"
EXP="SAM-3km-cyclone"

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/cyclone/output"
DIR_OUT="/marconi/home/userexternal/mdasilva/user/mdasilva/cyclone/post"
BIN="/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v2/scripts/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo 
echo "1. Select variable"

for MON in `seq -w 06 08`; do

    cdo selname,hus ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100.nc hus_${EXP}_${YEAR}${MON}0100.nc
    cdo selname,ta ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100.nc ta_${EXP}_${YEAR}${MON}0100.nc
    cdo selname,ua ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100.nc ua_${EXP}_${YEAR}${MON}0100.nc
    cdo selname,va ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100.nc va_${EXP}_${YEAR}${MON}0100.nc
    cdo selname,wa ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100.nc wa_${EXP}_${YEAR}${MON}0100.nc

    cdo selname,hfss ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc hfss_${EXP}_${YEAR}${MON}0100.nc
    cdo selname,hfls ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc hfls_${EXP}_${YEAR}${MON}0100.nc
    cdo selname,psl ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc psl_${EXP}_${YEAR}${MON}0100.nc
    cdo selname,uas ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc uas_${EXP}_${YEAR}${MON}0100.nc
    cdo selname,vas ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc vas_${EXP}_${YEAR}${MON}0100.nc

    cdo selname,pr ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc pr_${EXP}_${YEAR}${MON}0100.nc
    cdo selname,tas ${DIR_IN}/${EXP}_STS.${YEAR}${MON}0100.nc tas_${EXP}_${YEAR}${MON}0100.nc
   	    
done	

echo 
echo "2. Concatenate variable"

cdo mergetime hus_${EXP}_${YEAR}${MON}0100.nc hus_${EXP}_ECMWF_ERA5_ICTP_RegCM5_6h_${DATE}.nc
cdo mergetime ta_${EXP}_${YEAR}${MON}0100.nc ta_${EXP}_ECMWF_ERA5_ICTP_RegCM5_6h_${DATE}.nc
cdo mergetime ua_${EXP}_${YEAR}${MON}0100.nc ua_${EXP}_ECMWF_ERA5_ICTP_RegCM5_6h_${DATE}.nc
cdo mergetime va_${EXP}_${YEAR}${MON}0100.nc va_${EXP}_ECMWF_ERA5_ICTP_RegCM5_6h_${DATE}.nc
cdo mergetime wa_${EXP}_${YEAR}${MON}0100.nc wa_${EXP}_ECMWF_ERA5_ICTP_RegCM5_6h_${DATE}.nc

cdo mergetime hfss_${EXP}_${YEAR}${MON}0100.nc hfss_${EXP}_ECMWF_ERA5_ICTP_RegCM5_3h_${DATE}.nc
cdo mergetime hfls_${EXP}_${YEAR}${MON}0100.nc hfls_${EXP}_ECMWF_ERA5_ICTP_RegCM5_3h_${DATE}.nc
cdo mergetime psl_${EXP}_${YEAR}${MON}0100.nc psl_${EXP}_ECMWF_ERA5_ICTP_RegCM5_3h_${DATE}.nc
cdo mergetime uas_${EXP}_${YEAR}${MON}0100.nc uas_${EXP}_ECMWF_ERA5_ICTP_RegCM5_3h_${DATE}.nc
cdo mergetime vas_${EXP}_${YEAR}${MON}0100.nc vas_${EXP}_ECMWF_ERA5_ICTP_RegCM5_3h_${DATE}.nc

cdo mergetime pr_${EXP}_${YEAR}${MON}0100.nc pr_${EXP}_ECMWF_ERA5_ICTP_RegCM5_day_${DATE}.nc
cdo mergetime tas_${EXP}_${YEAR}${MON}0100.nc tas_${EXP}_ECMWF_ERA5_ICTP_RegCM5_day_${DATE}.nc

echo 
echo "3. Delete files"

rm *_${EXP}_*0100.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"
