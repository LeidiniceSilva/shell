#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '01/26/19'
#__description__ = 'Creating new areas from CMIP5 models and obs database with CDO'
 

echo
echo "--------------- INIT POSPROCESSING CMIP5 MODELS ----------------"

# Variables list
var_list=('pr' 'tas')     

# Models list
model_list=( 'BCC-CSM1.1' 'BCC-CSM1.1M' 'BNU-ESM' 'CanESM2' 'CNRM-CM5' 'CSIRO-ACCESS-1' 'CSIRO-ACCESS-3' 'CSIRO-MK36' 'ensmean_cmip5' 'FIO-ESM' 'GISS-E2-H-CC' 'GISS-E2-H' 'HadGEM2-AO' 'HadGEM2-CC' 'HadGEM2-ES' 'INMCM4' 'IPSL-CM5A-LR' 'IPSL-CM5A-MR' 'LASG-FGOALS-G2' 'LASG-FGOALS-S2' 'MIROC5' 'MIROC-ESM-CHEM' 'MIROC-ESM' 'MPI-ESM-LR' 'MPI-ESM-MR' 'MRI-CGCM3' 'NCAR-CCSM4' 'NCAR-CESM1-BGC' 'NCAR-CESM1-CAM5' 'NorESM1-ME' 'NorESM1-M')    

for var in ${var_list[@]}; do
    for model in ${model_list[@]}; do

	path="/home/nice/Documents/ufrn/phd_project/datas/cmip5/hist"
	cd ${path}
	
	echo
	echo ${path}

	# Experiment name
	exp=( 'historical_r1i1p1' ) 

	echo
	echo "Posprocessing file:" ${var}"_amz_neb_Amon_"${model}"_"${exp}"_197512-200511.nc"

	echo
	echo "1. Select new area: amz (-68,-52,-12,-3), neb (-40,-35,-16,-3) and matopiba (-50.5,-42.5,-15,-2.5)"
	#cdo sellonlatbox,-68,-52,-12,-3 ${var}_amz_neb_Amon_${model}_${exp}_197512-200511.nc ${var}_samz_Amon_${model}_${exp}_197512-200511.nc
	#cdo sellonlatbox,-40,-35,-16,-3 ${var}_amz_neb_Amon_${model}_${exp}_197512-200511.nc ${var}_eneb_Amon_${model}_${exp}_197512-200511.nc
	cdo sellonlatbox,-50.5,-42.5,-15,-2.5 ${var}_amz_neb_Amon_${model}_${exp}_197512-200511.nc ${var}_matopiba_Amon_${model}_${exp}_197512-200511.nc
    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

