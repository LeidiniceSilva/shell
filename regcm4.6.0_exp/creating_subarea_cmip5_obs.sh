#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '01/26/19'
#__description__ = 'Creating new areas from CMIP5 models and obs database with CDO'
 

echo
echo "--------------- INIT POSPROCESSING CMIP5 MODELS ----------------"

# Variables list
var_list=('pr' 'tas')     

# Models list
model_list=( 'BCC-CSM1.1' 'BCC-CSM1.1M' 'BNU-ESM' 'CanESM2' 'CMCC-CM' 'CMCC-CMS' 'CNRM-CM5' 'CSIRO-ACCESS-1' 'CSIRO-ACCESS-3' 'CSIRO-MK36' 'EC-EARTH' 'ensmean_cmip5' 'FIO-ESM' 'GFDL-ESM2G' 'GFDL-ESM2M' 'GISS-E2-H-CC' 'GISS-E2-H' 'GISS-E2-R-CC' 'GISS-E2-R' 'HadGEM2-AO' 'HadGEM2-CC' 'HadGEM2-ES' 'INMCM4' 'IPSL-CM5A-LR' 'IPSL-CM5A-MR' 'IPSL-CM5B-LR' 'LASG-FGOALS-G2' 'LASG-FGOALS-S2' 'MIROC5' 'MIROC-ESM-CHEM' 'MIROC-ESM' 'MPI-ESM-LR' 'MPI-ESM-MR' 'MRI-CGCM3' 'NCAR-CCSM4' 'NCAR-CESM1-BGC' 'NCAR-CESM1-CAM5' 'NorESM1-ME' 'NorESM1-M')    

for var in ${var_list[@]}; do
    for model in ${model_list[@]}; do

	path="/home/nice/Documentos/ufrn/PhD_project/datas/cmip5_hist"
	cd ${path}
	
	echo
	echo ${path}

	# Experiment name
	exp=( 'historical_r1i1p1' ) 

	echo
	echo "Posprocessing file:" ${var}"_amz_neb_Amon_"${model}"_"${exp}"_197512-200511.nc"

	echo
	echo "1. Select new area: amz (-74,-48,4,-16) and neb (-46,-34,-2,-15)"
	cdo sellonlatbox,-74,-48,4,-16 ${var}_amz_neb_Amon_${model}_${exp}_197512-200511.nc ${var}_amz_Amon_${model}_${exp}_197512-200511.nc
	cdo sellonlatbox,-46,-34,-2,-15 ${var}_amz_neb_Amon_${model}_${exp}_197512-200511.nc ${var}_neb_Amon_${model}_${exp}_197512-200511.nc

    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"
