#!/bin/bash

#__author__ = 'Leidinice Silva'
#__email__  = 'leidinicesilva@gmail.br'
#__date__   = '04/26/2018'

# Download -----------------> ein15

for YEAR in `seq 1979 2017`; do
	    
    echo ${YEAR} 

    PATH="/home/nice/Documentos/ein15_sst/" 

    echo
    cd ${PATH}

    /usr/bin/wget -N http://clima-dods.ictp.it/regcm4/EIN15/SST/sst.${YEAR}.nc

done	



