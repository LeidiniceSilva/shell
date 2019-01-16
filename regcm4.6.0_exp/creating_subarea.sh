#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '09/23/18'
#__description__ = 'Creatin subareas domain'
 

echo "--------------- INIT POSPROCESSING ----------------"
echo

for DATA in regcm_exp1 regcm_exp2 cmap_obs trmm_obs; do

    echo "1. Posprosseing database: ${DATA}"
    echo

    cdo sellonlatbox,-72,-62,-10,-4 pre_amz_neb_${DATA}_2005_monmean.nc pre_amz_neb_${DATA}_2005_monmean_A1.nc
    cdo sellonlatbox,-63.8,-58.5,-1.9,5.5 pre_amz_neb_${DATA}_2005_monmean.nc pre_amz_neb_${DATA}_2005_monmean_A2.nc
    cdo sellonlatbox,-71,-64.9,-2,2 pre_amz_neb_${DATA}_2005_monmean.nc pre_amz_neb_${DATA}_2005_monmean_A3.nc
    cdo sellonlatbox,-57,-49,-4,2 pre_amz_neb_${DATA}_2005_monmean.nc pre_amz_neb_${DATA}_2005_monmean_A4.nc
    cdo sellonlatbox,-57,-48.3,-9.5,-5 pre_amz_neb_${DATA}_2005_monmean.nc pre_amz_neb_${DATA}_2005_monmean_A5.nc
    cdo sellonlatbox,-75,-68,-15.5,-12 pre_amz_neb_${DATA}_2005_monmean.nc pre_amz_neb_${DATA}_2005_monmean_A6.nc
    cdo sellonlatbox,-78,-74.5,-10,-3 pre_amz_neb_${DATA}_2005_monmean.nc pre_amz_neb_${DATA}_2005_monmean_A7.nc
    cdo sellonlatbox,-36,-34.5,-10,-5  pre_amz_neb_${DATA}_2005_monmean.nc pre_amz_neb_${DATA}_2005_monmean_A8.nc
    cdo sellonlatbox,-41.3,-36.3,-8,-2.5 pre_amz_neb_${DATA}_2005_monmean.nc pre_amz_neb_${DATA}_2005_monmean_A9.nc
    cdo sellonlatbox,-46.5,-37.5,-12,-8.7 pre_amz_neb_${DATA}_2005_monmean.nc pre_amz_neb_${DATA}_2005_monmean_A10.nc
    cdo sellonlatbox,-41,-37.8,-18.3,-12.2 pre_amz_neb_${DATA}_2005_monmean.nc pre_amz_neb_${DATA}_2005_monmean_A11.nc
    cdo sellonlatbox,-46.5,-42.5,-8,-2 pre_amz_neb_${DATA}_2005_monmean.nc pre_amz_neb_${DATA}_2005_monmean_A12.nc
    
done

echo "--------------- THE END POSPROCESSING ----------------"
echo
