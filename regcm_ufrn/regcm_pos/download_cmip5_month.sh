#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '11/19/2018'
#__description__ = 'Download CMIP5 monthly historical data'

echo
echo "--------------- INIT DOWNLOAD CMIP5 MODELS ----------------"

# Variables list
var_list=('evspsbl hfls hfss huss pr ps psl rsds rsus tas tasmax tasmin')

for var in ${var_list[@]}; do
    for year in $(/usr/bin/seq -w 1900 10 2010) ; do

	path="/home/nice/Downloads"
	cd ${path}

	# Model name
	model=('LASG-FGOALS-G2')

	# Experiment name
	exp=('historical_r1i1p1')

	# Date
	in_date=${year}

	if [ ${year} == '2010' ]
	then
	fi_date=$(date -I -d "${year}-12-28 + 4 years" | sed -n '1p' | cut -d '-' -f 1 )
	else
	fi_date=$(date -I -d "${year}-12-28 + 9 years" | sed -n '1p' | cut -d '-' -f 1 )
	fi

	echo "Starting download:" ${var}"_Amon_"${model}"_"${exp}"_"${in_date}"-"${fi_date}".nc"
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

	/usr/bin/wget -N -c http://clima-dods.ictp.it/Data/CMIP5/monthly/hist/${model}/${var}_Amon_FGOALS-g2_${exp}_${in_date}01-${fi_date}12.nc
	mv ${var}_Amon_FGOALS-g2_${exp}_${in_date}01-${fi_date}12.nc ${var}_Amon_${model}_${exp}_${in_date}01-${fi_date}12.nc

	echo "Ending download:" ${var}_Amon_${model}_${exp}_${in_date}01-${fi_date}12.nc
	echo
    
    done
done

echo
echo "--------------- THE END DOWNLOAD CMIP5 MODELS ----------------"
