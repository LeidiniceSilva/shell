#!/bin/bash

#__author__ = 'Leidinice Silva'
#__email__  = 'leidinicesilva@gmail.br'
#__date__   = '05/04/2018'

# Download via ftp -----------------> ein15

for YEAR in `seq 1979 2017`; do
	    
    echo ${YEAR} 

    PATH="/home/xxxx/Documentos/ein15_sst/" #coloca o nome do seu usuario onde tem xxxx e cria a pasta 'ein15_precip'

    echo
    cd ${PATH}

    /usr/bin/wget -N http://clima-dods.ictp.it/regcm4/EIN15/SST/sst_${YEAR}.nc

done	



