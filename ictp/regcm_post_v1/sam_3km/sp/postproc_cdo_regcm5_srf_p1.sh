#!/bin/bash

#SBATCH -A CMPNS_ictpclim
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
#__description__ = 'Posprocessing the RegCM5 output with CDO'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="2018-2021"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

EXP="SAM-3km"
VAR_LIST="pr"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_scratch/SAM-3km/output"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_scratch/SAM-3km/sp"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    for YEAR in `seq -w ${IYR} ${FYR}`; do
        for MON in `seq -w 01 12`; do
            CDO selname,${VAR} ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
	    CDO sellonlatbox,-47.3,-45.3,-25,-23.1 ${VAR}_${EXP}_${YEAR}${MON}0100.nc ${VAR}_${EXP}_SP_${YEAR}${MON}0100.nc
	    CDO -b f32 mulc,3600 ${VAR}_${EXP}_SP_${YEAR}${MON}0100.nc ${VAR}_${EXP}_SP_1hr_${YEAR}${MON}0100.nc
	done
    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
