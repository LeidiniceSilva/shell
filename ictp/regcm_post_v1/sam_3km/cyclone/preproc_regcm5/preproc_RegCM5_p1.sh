#!/bin/bash

#SBATCH -A ICT25_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 15, 2024'
#__description__ = 'Postprocessing the RegCM5 output with CDO'
 
{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

VAR_LIST="psl uas vas"
EXP="SAM-3km"
MODEL="RegCM5"
DT="2018-2021"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/rcm/output"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/cyclone/RegCM5"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"
MASK="/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v1/sam_3km/cyclone/mask"
   
echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    for YEAR in `seq -w 2018 2021`; do
        for MON in `seq -w 01 12`; do
	    
	    echo
	    echo "1. Select variable"
	    CDO selname,${VAR} ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc ${VAR}_${MODEL}_1hr_${YEAR}${MON}0100.nc

	    echo
	    echo "2. Regrid"
	    #${BIN}/./regrid ${VAR}_${MODEL}_1hr_${YEAR}${MON}0100.nc -34.5,-15,1.5 -76,-38.5,1.5 bil
	    CDO remapbil,${MASK}/gridded.txt ${VAR}_${MODEL}_1hr_${YEAR}${MON}0100.nc ${VAR}_${MODEL}_1hr_${YEAR}${MON}0100_lonlat.nc

	    echo
	    echo "3. Smooth"
	    CDO smooth ${VAR}_${MODEL}_1hr_${YEAR}${MON}0100_lonlat.nc ${VAR}_${EXP}_${MODEL}_1hr_${YEAR}${MON}0100_smooth.nc
	    CDO smooth ${VAR}_${EXP}_${MODEL}_1hr_${YEAR}${MON}0100_smooth.nc ${VAR}_${EXP}_${MODEL}_1hr_${YEAR}${MON}0100_smooth2.nc
	    
        done
    done

    echo
    echo "4. Merge files"  
    CDO mergetime ${VAR}_${EXP}_${MODEL}_1hr_*0100_smooth2.nc ${VAR}_${EXP}_${MODEL}_1hr_${DT}_smooth2.nc
    #CDO selyear,2018/2021 ${VAR}_${EXP}_${MODEL}_1hr_2017-2021_smooth2.nc ${VAR}_${EXP}_${MODEL}_1hr_${DT}_smooth2.nc

done
    
echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
