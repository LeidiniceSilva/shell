 #!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '11/08/18'
#__description__ = 'Preprocessing the RegCM4.7 model data with CDO'
 

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"


EXP='exp14'
DIR='/home/rcm13/dados/output'

echo 
cd ${DIR}
echo ${DIR}

echo 
echo "1. cdo concatenate files"

cdo cat NEB_RCM_${EXP}_STS.20100[3-8]0100.nc NEB_RCM_${EXP}_STS_season_2010.nc

echo 
echo "2. cdo select variable - precipitation"

cdo selname,pr NEB_RCM_${EXP}_STS_season_2010.nc NEB_RCM_${EXP}_pre_flux_season_2010.nc

echo 
echo "3. cdo convert unit - flux ---> mm"

cdo mulc,86400 NEB_RCM_${EXP}_pre_flux_season_2010.nc NEB_RCM_${EXP}_pre_season_day_2010.nc

echo
echo "4. cdo compute mon mean"

cdo monmean NEB_RCM_${EXP}_pre_season_day_2010.nc NEB_RCM_${EXP}_pre_season_mon_2010.nc

echo
echo "5. Grads prepare .ctl"

./GrADSNcPrepare NEB_RCM_${EXP}_pre_season_day_2010.nc
./GrADSNcPrepare NEB_RCM_${EXP}_pre_season_mon_2010.nc

echo
echo "deleted files"

rm -f NEB_RCM_${EXP}_STS_season_2010.nc
rm -f NEB_RCM_${EXP}_pre_flux_season_2010.nc


echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"





