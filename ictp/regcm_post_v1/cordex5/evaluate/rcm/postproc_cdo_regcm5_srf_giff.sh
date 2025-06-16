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
#__description__ = 'Posprocessing the RegCM5 output with CDO'
 
{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

FREQ="1hr"
DOMAIN="CSAM-3"
EXP="RegCM5"

YR="2000-2000"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

VAR_LIST="pr"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/ERA5/ERA5-CSAM-3"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/rcm"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "Select variable"
for VAR in ${VAR_LIST[@]}; do
    for YEAR in `seq -w ${IYR} ${FYR}`; do
        for MON in `seq -w 01 01`; do
	    for DAY in `seq -w 01 31`; do
		CDO selname,${VAR} ${DIR_IN}/CSAM-3_SRF.${YEAR}${MON}${DAY}00.nc ${VAR}_${DOMAIN}_${YEAR}${MON}${DAY}00.nc
	    done
	done
    done

    echo
    echo "Merge files"
    CDO mergetime ${VAR}_${DOMAIN}_*00.nc ${VAR}_${DOMAIN}_200001.nc

    echo
    echo "Convert unit and regrid"
    CDO -b f32 mulc,3600 ${VAR}_${DOMAIN}_200001.nc ${VAR}_${DOMAIN}_${EXP}_${FREQ}_200001.nc
    ${BIN}/./regrid ${VAR}_${DOMAIN}_${EXP}_${FREQ}_200001.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
      
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
