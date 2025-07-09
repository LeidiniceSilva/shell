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
#__date__        = 'Nov 20, 2023'
#__description__ = 'Postprocessing the WRF output with CDO'

{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="SAM-4km"
MODEL="WRF"
DT="2018-2021"
VAR_LIST="PSL U10 V10"

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/cyclone/WRF415"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do

    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}
    
    for YR in `seq -w 2018 2021`; do
        CDO selyear,$YR ${VAR}_${EXP}_${MODEL}_${DT}_smooth2.nc ${VAR}_${EXP}_${MODEL}_${YR}.nc
   	
	for HR in 00 06 12 18; do
            CDO selhour,$HR ${VAR}_${EXP}_${MODEL}_${YR}.nc ${VAR}.${YR}.${HR}.nc
	                
	done
    done
done
    
echo
echo "--------------- THE END POSPROCESSING MODEL -------------"

}
