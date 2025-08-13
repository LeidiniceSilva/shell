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
#__date__        = 'Mar 12, 2024'
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 
{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="EUR-11"

YR="2008-2008"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

MON="12-12"
IMON=$( echo $MON | cut -d- -f1 )
FMON=$( echo $MON | cut -d- -f2 )

FOLDER_LIST="NoTo-EUR WSM5-EUR WSM7-EUR WDM7-EUR"

echo
echo "--------------- INIT POSTPROCESSING MODEL ----------------"

for FOLDER in ${FOLDER_LIST[@]}; do

    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/${FOLDER}"
    DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/postproc/rcm"
    BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}

    VAR_LIST="pr psl uas vas ta ua va wa"

    echo
    echo "1. Select variable"
    for VAR in ${VAR_LIST[@]}; do

        for YEAR in `seq -w ${IYR} ${FYR}`; do
	    for MON in `seq -w ${IMON} ${FMON}`; do
                if [ ${VAR} = pr ] || [ ${VAR} = psl ] || [ ${VAR} = uas ] || [ ${VAR} = vas ] 
                then
                CDO selname,${VAR} ${DIR_IN}/${EXP}_SRF.${YEAR}${MON}0100.nc ${VAR}_RegCM5_${FOLDER}_${YEAR}${MON}.nc
                else
                CDO selname,${VAR} ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100_pressure.nc ${VAR}_RegCM5_${FOLDER}_${YEAR}${MON}.nc
                fi
	    done
	done
    
        echo 
        echo "2. Regrid"
	${BIN}/./regrid ${VAR}_RegCM5_${FOLDER}_${YEAR}${MON}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
    
    echo 
    echo "3. Delete files"
    rm *_RegCM5_${FOLDER}_${YEAR}${MON}.nc

    done
done

echo
echo "--------------- THE END POSTPROCESSING MODEL ----------------"

}
