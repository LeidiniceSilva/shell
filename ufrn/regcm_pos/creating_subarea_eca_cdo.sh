#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '06/22/2021'
#__description__ = 'Creating new areas of ETCCDI indices with CDO'
 

echo
echo "--------------- INIT POSPROCESSING ETCCDI INDICES ----------------"

# Variables list
exp=('rcp85') 
time=('2080-2099')
data=('RegCM47_had')

# Variables list
var_list=('cdd' 'cwd' 'dtr' 'prcptot' 'r10mm' 'r20mm' 'r95p' 'r99p' 'rx1day' 'rx5day' 'sdii' 'su' 'tn10p' 'tn90p' 'tnn' 'tnx' 'tr' 'tx10p' 'tx90p' 'txn' 'txx')    

for var in ${var_list[@]}; do
    
    path="/home/nice/Documents/dataset/rcm/eca"
    cd ${path}

    echo
    echo "Posprocessing file:" eca_${var}_amz_neb_${data}_${exp}_yr_${time}_lonlat.nc

    echo
    echo "1. Select new area: samz (-68,-52,-12,-3)"
    cdo sellonlatbox,-68,-52,-12,-3 eca_${var}_amz_neb_${data}_${exp}_yr_${time}_lonlat.nc eca_${var}_samz_${data}_${exp}_yr_${time}_lonlat.nc

    echo "2. Select new area: eneb (-40,-35,-16,-3)"
    cdo sellonlatbox,-40,-35,-16,-3 eca_${var}_amz_neb_${data}_${exp}_yr_${time}_lonlat.nc eca_${var}_eneb_${data}_${exp}_yr_${time}_lonlat.nc

    echo "3. Select new area: matopiba (-50.5,-42.5,-15,-2.5)"
    cdo sellonlatbox,-50.5,-42.5,-15,-2.5 eca_${var}_amz_neb_${data}_${exp}_yr_${time}_lonlat.nc eca_${var}_matopiba_${data}_${exp}_yr_${time}_lonlat.nc 

done

echo
echo "--------------- THE END POSPROCESSING ETCCDI INDICES ----------------"

