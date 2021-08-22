#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '05/10/2018'
#__description__ = 'Creating .ctl with GrADSNcPrepare'


cd /vol3/disco1/nice/data_file/regcm_data/exp_pbl/output_exp1

for VAR in STS; do 
    for YEAR in `seq 2006 2010`; do       
        for MON in `seq -w 1 12`; do
    
    	    echo ${VAR} - ${YEAR} - ${MON} 
	
	    /users/nice/RegCM-4.6.0/bin/GrADSNcPrepare amz_neb_${VAR}.${YEAR}${MON}0100.nc

        done
    done
done	
