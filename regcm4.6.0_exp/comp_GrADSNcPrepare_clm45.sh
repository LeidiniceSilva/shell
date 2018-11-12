#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '05/10/18'
#__description__ = 'Creating .ctl with GrADSNcPrepareCLM45'


cd /vol3/disco1/nice/PNT_2018/output_exp6/CLM4.5	

for VAR in ATM RAD SRF STS; do 
    for YEAR in `seq 2011 2013`; do       
        for MON in `seq -w 1 12`; do
    
    	    echo ${VAR} - ${YEAR} - ${MON} 
	    echo
	    
	    echo Creating .ctl with GrADSNcPrepareCLM45
	    echo	    
	    /users/nice/CLM4.5/RegCM-4.6.0/bin/GrADSNcPrepareCLM45 amz_neb_exp6_${VAR}.${YEAR}${MON}0100.nc 
	    
        done
    done
done	


for YEAR in `seq 2011 2013`; do       
    for MON in `seq -w 1 12`; do
	
	echo Convert 1d to 2d
	echo
	/users/nice/CLM4.5/RegCM-4.6.0/bin/clm45_1dto2dCLM45 amz_neb_exp6.clm.regcm.h0.${YEAR}${MON}.nc
	    
        echo Make .ctl from h0
	echo
	/users/nice/CLM4.5/RegCM-4.6.0/Tools/Scripts/clm45_makectl.sh amz_neb_exp6.clm.regcm.h0.${YEAR}${MON}_2d.nc amz_neb_exp6_SRF.${YEAR}${MON}0100.nc.ctl

    done
done	    
