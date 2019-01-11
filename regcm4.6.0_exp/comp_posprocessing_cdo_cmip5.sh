#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '01/11/19'
#__description__ = 'Posprocessing the CMIP5 model data with CDO'
 

echo
echo "--------------- INIT POSPROCESSING CMIP5 MODELS ----------------"

var_list=('pr')
model_list=('BCC-CSM1-1')

for var in ${var_list[@]}; do
    for model in ${model_list[@]}; do

	path="/home/nice/Downloads"
	cd ${path}

	# Experiment name
	exp=('historical_r1i1p1')

	# Date
	date=('185001-201212')
	
	echo
	echo "Starting with:" ${path}"/"${var}"_""Amon""_"${model}"_"${exp}"_"${date}".nc"

	echo 
	echo "1. Select data: 198001-200512"

	cdo seldate,1980-01-00T00:00:00,2005-12-31T00:00:00 ${var}_Amon_${model}_${exp}_${date}.nc ${var}_Amon_${model}_${exp}_198001-200512.nc 

	echo 
	echo "2. Unit convention: flux to mm"

	cdo mulc,86400 ${var}_Amon_${model}_${exp}_198001-200512.nc ${var}_Amon_${model}_${exp}_mon_198001-200512.nc 

	echo 
	echo "3. Remapbil: r360x180"

	cdo remapbil,r360x180, ${var}_Amon_${model}_${exp}_mon_198001-200512.nc ${var}_newgrid_Amon_${model}_${exp}_mon_198001-200512.nc

	echo 
	echo "4. Sellonlatbox: -85,-15,-20,10"

	cdo sellonlatbox,-85,-15,-20,10 ${var}_newgrid_Amon_${model}_${exp}_mon_198001-200512.nc ${var}_amz_neb_Amon_${model}_${exp}_mon_198001-200512.nc

	echo 
	echo "5. Deleted files"

	rm ${var}_Amon_${model}_${exp}_198001-200512.nc
        rm ${var}_Amon_${model}_${exp}_mon_198001-200512.nc
	rm ${var}_newgrid_Amon_${model}_${exp}_mon_198001-200512.nc

    done
done

echo
echo "--------------- THE END POSPROCESSING CMIP5 MODELS ----------------"

