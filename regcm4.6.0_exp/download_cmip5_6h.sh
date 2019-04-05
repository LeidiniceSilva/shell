#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '04/05/2018'
#__description__ = 'Download HadGEM2-ES CMIP5 model to downscaling with RegCM4.7'


echo
echo "--------------- INIT DOWNLOAD HadGEM2-ES CMIP5 MODEL ----------------"

# Variables list
var_list=('hus ps ta ua va')

for var in ${var_list[@]}; do
    for year in $(/usr/bin/seq -w 1949 2005); do
	for mon in $(/usr/bin/seq -w 03 3 12); do
	    
            path="/vol3/disco1/nice/data_file/cmip_data/cmip5/hadgem2-es_downscaling"
	    cd ${path}

	    # Model time
	    time=('6hrLev')

	    # Model name
	    model=('HadGEM2-ES')

	    # Experiment name
	    exp=('historical_r1i1p1')

	    # Date
	    in_date=${year}${mon}

	    if [ ${mon} == '12' ]
	    then
	    fi_date=$(date -I -d "${year}${mon}-12-28 - 9 months" | sed -n '1p' | cut -d '-' -f 1 )
	    else
	    fi_date=$(date -I -d "${year}${mon}-12-28 + 3 months" | sed -n '1p' | cut -d '-' -f 1 )
	    fi

	    echo "Starting download: ${var}_${time}_${model}_${exp}_${in_date}_${fi_date}.nc"
	    echo 
	
	    # Creating path model
	    var_path=${path}/${var}

	    if [ ! -d ${var} ]
	    then
	    mkdir ${var}
	    else
	    echo "Directory already exists"
	    echo
	    fi

	    cd ${var}

	    /usr/bin/wget -N -c http://clima-dods.ictp.it/Data/RegCM_Data/HadGEM2/RF/${var}/${var}_${time}_${model}_${exp}_${in_date}0106_${fi_date}0100.nc

	    echo "Ending download: ${var}_${time}_${model}_${exp}_${in_date}_${fi_date}.nc"
	    echo

	done    
    done
done

echo
echo "--------------- THE END DOWNLOAD CMIP5 MODELS ----------------"
