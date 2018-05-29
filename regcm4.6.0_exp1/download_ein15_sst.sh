#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '04/26/2018'
#__description__ = 'Download EIN15 sea surface temperature data'


for YEAR in `seq 1979 2017`; do
	    
    echo ${YEAR} 

    PATH="/vol3/DADOS_CONTORNO_REGCM46/EIN15/SST/"

    echo
    cd ${PATH}

    /usr/bin/wget -N http://clima-dods.ictp.it/regcm4/EIN15/SST/sst.${YEAR}.nc

done	



