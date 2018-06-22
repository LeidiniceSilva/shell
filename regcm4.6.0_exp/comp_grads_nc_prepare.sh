#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '05/10/18'
#__description__ = 'To Convert NetCDF in .ctl with GrADSNcPrepare'


cd /vol3/nice/output2

for VAR in ATM RAD SRF STS; do 
    for YEAR in `seq 2001 2005`; do       
        for MON in `seq -w 1 12`; do
    
    	    echo ${VAR} - ${YEAR} - ${MON} 
	
	    ./GrADSNcPrepare amz_neb_${VAR}.${YEAR}${MON}0100.nc

        done
    done
done	


