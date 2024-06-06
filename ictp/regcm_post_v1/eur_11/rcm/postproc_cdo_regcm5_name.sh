#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jun 06, 2024'
#__description__ = 'Posprocessing the RegCM5 output with CDO'

DIR_IN="/marconi/home/userexternal/mdasilva/user/mdasilva/EUR-11/WDM7-Europe"

for  MON in {01..12}; do

	echo
	cd ${DIR_IN}
	echo ${DIR_IN}
	
	cp test_001_ATM.2000${MON}0100.nc EUR-111_ATM.2000${MON}0100.nc
	cp test_001_RAD.2000${MON}0100.nc EUR-111_RAD.2000${MON}0100.nc
	cp test_001_SRF.2000${MON}0100.nc EUR-111_SRF.2000${MON}0100.nc
	cp test_001_STS.2000${MON}0100.nc EUR-111_STS.2000${MON}0100.nc

done
