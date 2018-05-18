#!/bin/bash

#__author__ = 'Leidinice Silva'
#__email__  = 'leidinicesilva@gmail.br'
#__date__   = '04/26/2018'

# Download -----------------> ein15

for YEAR in `seq 1979 2014`; do
	    
    echo ${YEAR} 

    PATH="/home/nice/Documentos/ein15_tas/"

    echo
    cd ${PATH}

    /usr/bin/wget -N http://clima-dods.ictp.it/regcm4/EIN15/surface/erai_tas_${YEAR}0101_${YEAR}1231_00_1.50.nc

done	



