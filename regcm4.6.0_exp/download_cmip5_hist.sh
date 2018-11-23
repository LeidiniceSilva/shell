#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '11/19/2018'
#__description__ = 'Download CMIP5 monthly historical data'


MODELS_LIST = ('CanESM2' 'CSIRO')  
VARS_LIST = ( 'tos_Omon' )  

for MODEL in ${MODELS_LIST[@]}; do 
    for VAR in ${VARS_LIST[@]}; do
	    
    	echo ${MODEL} - ${VAR}
	
	PATH="/vol3/disco1/nice/cmip5/cmip5_hist/${MODEL}"
	
	echo ${PATH}
	
	cd ${PATH}
	    
	mkdir ${MODEL}


	/usr/bin/wget -N http://clima-dods.ictp.it/Data/CMIP5/monthly/hist/${MODEL}/*.nc

    done
done	
