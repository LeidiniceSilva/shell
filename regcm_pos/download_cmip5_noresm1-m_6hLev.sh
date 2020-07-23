#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '07/22/2020'
#__description__ = 'Download NorESM1-M CMIP5 model'


echo
echo "--------------- INIT DOWNLOAD NorESM1-M CMIP5 MODEL ----------------"

# Variables list
var_list=('hus')

for var in ${var_list[@]}; do

    path="/vol1/nice/NorESM1-M"
    
    cd ${path}
	    
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

    for year in $(/usr/bin/seq -w 1995 2005); do
	
	for mon in 01 07; do
	
	    # Model time
	    time=('6hrLev')

	    # Model name
	    model=('NorESM1-M')

	    # Experiment name
	    exp=('historical_r1i1p1')
	    
	    # Date
            in_date=${year}${mon}'0100'    
            fi_date=${year}'063018'

	    if [ ${mon} == '07' ]
	    then
	    fi_date=${year}'123118'
	    fi
	    
	    echo "Starting download: ${var}_${time}_${model}_${exp}_${in_date}-${fi_date}.nc"
	    echo 
	
	    /usr/bin/wget -N -c http://clima-dods.ictp.it/Data/RegCM_Data/NorESM1-M/RF/${var}/${var}_${time}_${model}_${exp}_${in_date}-${fi_date}.nc

	    echo "Ending download: ${var}_${time}_${model}_${exp}_${in_date}-${fi_date}.nc"
	    echo

	done
    done
done

echo
echo "--------------- THE END DOWNLOAD NorESM1-M CMIP5 MODEL ----------------"

