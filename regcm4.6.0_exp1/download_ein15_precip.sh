#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '04/26/2018'
#__description__ = 'Download EIN15 precipitation data'


for YEAR in `seq 1979 2014`; do
	    
    echo ${YEAR} 

    PATH="/home/nice/Documentos/ein15_precip/" 

    echo
    cd ${PATH}

    /usr/bin/wget -N http://clima-dods.ictp.it/regcm4/EIN15/surface/erai_precip_${YEAR}0101_${YEAR}1231_00_1.50.nc

done	



