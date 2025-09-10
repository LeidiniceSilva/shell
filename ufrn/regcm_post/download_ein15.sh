#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '04/26/2018'
#__description__ = 'Download EIN15 contour data'

for YEAR in `seq 1979 2017`; do
    for VAR in air hgt qas rhum uwnd vwnd; do
    	for HOUR in 00 06 12 18; do
	    
    	    echo ${YEAR} - ${VAR} - ${HOUR}

	    if [ ! -d "${YEAR}" ]; then
	        echo "Directory ${YEAR} don't exist"
	        mkdir ${YEAR}
	    fi

	    cd ${YEAR}
	    pwd

	    PATH="/vol3/DADOS_CONTORNO_REGCM46/EIN15/${YEAR}/"

	    echo
	    cd ${PATH}

	    /usr/bin/wget -N http://clima-dods.ictp.it/regcm4/EIN15/${YEAR}/${VAR}.${YEAR}.${HOUR}.nc

        done
    done
done	



