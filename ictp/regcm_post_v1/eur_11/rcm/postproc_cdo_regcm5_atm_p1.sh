#!/bin/bash

#SBATCH -N 1
#SBATCH -t 24:00:00
#SBATCH -J Testing
#SBATCH -p esp
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

YR="2000-2001"

IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

EXP="EUR-11"
VAR_LIST="cl cli clr cls clw hus rh"
SEASON_LIST="DJF MAM JJA SON"
FOLDER_LIST="NoTo-Europe WDM7-Europe WSM7-Europe WSM5-Europe"

echo
echo "--------------- INIT POSTPROCESSING MODEL ----------------"

for FOLDER in ${FOLDER_LIST[@]}; do

    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/${FOLDER}"
    BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

    echo
    cd ${DIR_IN}
    echo ${DIR_IN}

    echo
    echo "1. Convert to sigma to pressure"
    for YEAR in `seq -w ${IYR} ${FYR}`; do
	for MON in `seq -w 01 12`; do
	    ${BIN}/./sigma2pCLM45 ${DIR_IN}/${EXP}_ATM.${YEAR}${MON}0100.nc
            ${BIN}/./sigma2pCLM45 ${DIR_IN}/${EXP}_RAD.${YEAR}${MON}0100.nc
	done
    done
done
    
echo
echo "--------------- THE END POSTPROCESSING MODEL ----------------"

}
