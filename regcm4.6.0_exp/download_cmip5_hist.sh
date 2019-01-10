#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '11/19/2018'
#__description__ = 'Download CMIP5 monthly historical data'


# Variables list
var_list=('hfls hfss pr ps psl rlds rlus rsds rsus tas tasmax tasmin uas vas')

for var in ${var_list[@]}; do
    for year in $(/usr/bin/seq -w 1850 10 1990) ; do

	path="/home/nice/Downloads"
	cd ${path}

	# Model name
	model=('CMCC-CMS')

	# Experiment name
	exp=('historical_r1i1p1')

	# Date
	in_date=${year}
	fi_date=$(date -I -d "${year}-12-28 + 9 years" | sed -n '1p' | cut -d '-' -f 1 )

	echo "Starting download:" ${var}"_"${model}"_"${exp}"_"${in_date}"-"${fi_date}
	echo

	# Creating path model
	model_path=${path}/${model}

	if [ ! -d ${model} ]
	then
	mkdir ${model}
	else

	echo "Directory already exists"
	echo

	fi

	cd ${model}

	/usr/bin/wget -N -c http://clima-dods.ictp.it/Data/CMIP5/monthly/hist/${model}/${var}_Amon_${model}_${exp}_${in_date}01-${fi_date}12.nc

	echo "Ending download:" ${var}_Amon_${model}_${exp}_${in_date}01-${fi_date}12.nc
	echo
    
    done
done
