#!/bin/bash

#__author__ = 'Leidinice Silva'
#__email__  = 'leidinicesilva@gmail.br'
#__date__   = '05/10/18'

# To Convert NetCDF in .ctl with GrADSNcPrepare

for VAR in ATM RAD SRF STS; do 
    for YEAR in `seq 2001 2005`; do         # Change year (Exemple: for YEAR in `seq 2006 2010`; do)
        for MON in 01 02 03 04 05 06 07 08 09 10 11 12; do
    
    	    echo ${VAR} - ${YEAR} - ${MON} 
	
	    ./GrADSNcPrepare amz_neb_${VAR}.${YEAR}${MON}0100.nc

        done
    done
done	


