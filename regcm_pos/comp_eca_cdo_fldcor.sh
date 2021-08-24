#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '08/22/2021'
#__description__ = 'Compute field correlation of ETCCDI indices with CDO'
 
echo
echo "--------------- INIT POSPROCESSING ETCCDI INDICES ----------------"

OBS="cpc_obs_yr"
SIM="HadGEM2-ES_historical_yr"
DATE="1986-2005_lonlat"
AREA="matopiba"

# Variables list
VAR_LIST=('eca_prcptot' 'eca_r95p' 'eca_r99p' 'eca_rx1day' 'eca_rx5day' 'eca_sdii' 'eca_cdd' 'eca_cwd' 'eca_r10mm' 'eca_r20mm' 'eca_txx' 'eca_txn' 'eca_tnx' 'eca_tnn' 'eca_dtr' 'eca_su' 'eca_tr' 'eca_tn10p' 'eca_tn90p' 'eca_tx10p' 'eca_tx90p')    

for VAR in ${VAR_LIST[@]}; do

    DIR_OBS="/home/nice/Documents/dataset/obs/eca/"
    DIR_SIM="/home/nice/Documents/dataset/gcm/eca/"

    cdo fldcor ${DIR_OBS}${VAR}_${AREA}_${OBS}_${DATE}.nc ${DIR_SIM}${VAR}_${AREA}_${SIM}_${DATE}.nc fdlcor_${VAR}_${AREA}_${SIM}.nc
    cdo timmean fdlcor_${VAR}_${AREA}_${SIM}.nc ${VAR}_${AREA}_${SIM}_fdlcor.nc
    rm -rf fdlcor_${VAR}_${AREA}_${SIM}.nc

    echo
    echo "File: fdlcor_${VAR}_${AREA}_${SIM}.nc"
    echo
    cdo infon ${VAR}_${AREA}_${SIM}_fdlcor.nc
    echo

done



echo
echo "--------------- THE END POSPROCESSING ETCCDI INDICES ----------------"
