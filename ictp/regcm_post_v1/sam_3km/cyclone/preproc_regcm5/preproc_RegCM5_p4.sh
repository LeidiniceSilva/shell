#!/bin/bash

#SBATCH -A ICT25_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 4
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

EXP="SAM-3km"
MODEL="RegCM5"
DT="2018-2021"
VAR_LIST="cape cin pr psl uas vas"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/output"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/cyclone/RegCM5"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    for YEAR in `seq -w 2018 2021`; do
        for MON in `seq -w 01 12`; do
	    
	    CDO selname,${VAR} ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc ${VAR}_${MODEL}_1hr_${YEAR}${MON}0100.nc
	    
        done
    done

    #if [ ${VAR} == "pr" ]
    #then
    #CDO mergetime ${VAR}_${MODEL}_1hr_*0100.nc ${VAR}_${MODEL}_1hr_${DT}.nc
    #CDO -b f32 mulc,3600 ${VAR}_${MODEL}_1hr_${DT}.nc ${VAR}_${EXP}_${MODEL}_1hr_${DT}.nc
    #CDO daysum ${VAR}_${EXP}_${MODEL}_1hr_${DT}.nc ${VAR}_${EXP}_${MODEL}_day_${DT}.nc
    #${BIN}/./regrid ${VAR}_${EXP}_${MODEL}_1hr_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    #${BIN}/./regrid ${VAR}_${EXP}_${MODEL}_day_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    #else
    #CDO mergetime ${VAR}_${MODEL}_1hr_*0100.nc ${VAR}_${EXP}_${MODEL}_1hr_${DT}.nc
    #CDO selhour,00,06,12,18 ${VAR}_${EXP}_${MODEL}_1hr_${DT}.nc ${VAR}_${EXP}_${MODEL}_6hr_${DT}.nc
    #${BIN}/./regrid ${VAR}_${EXP}_${MODEL}_6hr_${DT}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil
    #fi
   
done
    
echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
