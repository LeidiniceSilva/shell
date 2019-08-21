#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '11/19/2018'
#__description__ = 'Download RegCM4.7 simulation data DCA/IAG USP'


for VAR in tpr t2m; do
    for MOD in regMPI regHadGEM2 regGFDL; do
    	for SCHMES in bats clm; do
	    
    	    echo ${VAR} - ${MOD} - ${SCHMES}
	    PATH="/vol3/disco1/nice/results/PhD_project/reg_cda_iag/"

	    echo ${PATH}
	    cd ${PATH}

	    /usr/bin/wget -N ftp://ftpdca.iag.usp.br/rosmeri/Thiago2018/${VAR}_${MOD}_${SCHMES}_RCP85.1970-2099.nc

        done
    done
done	
