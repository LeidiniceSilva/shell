#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '05/10/18'
#__description__ = 'Creating .ctl with GrADSNcPrepare'


cd /vol3/disco1/nice/PNT_2018/output_exp6/BATS

for VAR in ATM RAD SRF STS; do 
    for YEAR in `seq 2011 2013`; do       
        for MON in `seq -w 1 12`; do
    
    	    echo ${VAR} - ${YEAR} - ${MON} 
	
	    /users/nice/RegCM-4.6.0/bin/GrADSNcPrepare amz_neb_exp6_${VAR}.${YEAR}${MON}0100.nc

        done
    done
done	


