#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '11/19/2018'
#__description__ = 'Download CMIP5 monthly historical data'


# Variables list
var_list=('evspsbl hfls hfss hurs huss pr ps psl rlds rlus rsds rsus tas tasmax tasmin uas vas')

for var in ${var_list[@]}; do
    for year in $(/usr/bin/seq -w 1850 10 1990) ; do

	path="/home/nice/Downloads"
	cd ${path}

	in_date=${year}

	fi_date=$(date -I -d "${year}-12-28 + 9 years" | sed -n '1p' | cut -d '-' -f 1 )

	# Models list
	model=('CMCC-CM')

	# Experiment
	exp_name=('historical_r1i1p1')

	echo ${var}"_"${model}"_"${exp_name}"_"${in_date}"-"${fi_date}
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
	pwd

	/usr/bin/wget -N -c http://clima-dods.ictp.it/Data/CMIP5/monthly/hist/${model}/${var}_Amon_${model}_${exp_name}_${in_date}01-${fi_date}12.nc

	echo "Saving files in path:" ${var}"_"${model}"_"${exp_name}"_"${in_date}"-"${fi_date}
	echo
    
    done
done
