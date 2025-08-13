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
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

VAR="pr"
EXP="HadREM3-RAL1T"
DOMAINS="SESA-3"

BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "Select variable"
for DOMAIN in ${DOMAINS[@]}; do

    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/CPRCM"
    DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/hpe/input/${DOMAIN}/CPRCM"

    cd ${DIR_OUT}
    echo ${DIR_OUT}

    for YEAR in `seq -w 2000 2007`; do

	${BIN}/./regrid ${DIR_IN}/${VAR}_E1hr_${EXP}_hindcast_r1i1p1f1_gn_${YEAR}01010030-${YEAR}03312330.nc -36.25,-20.25,0.0275 -65.25,-45.25,0.0275 bil
	${BIN}/./regrid ${DIR_IN}/${VAR}_E1hr_${EXP}_hindcast_r1i1p1f1_gn_${YEAR}04010030-${YEAR}06302330.nc -36.25,-20.25,0.0275 -65.25,-45.25,0.0275 bil
	${BIN}/./regrid ${DIR_IN}/${VAR}_E1hr_${EXP}_hindcast_r1i1p1f1_gn_${YEAR}07010030-${YEAR}09302330.nc -36.25,-20.25,0.0275 -65.25,-45.25,0.0275 bil
	${BIN}/./regrid ${DIR_IN}/${VAR}_E1hr_${EXP}_hindcast_r1i1p1f1_gn_${YEAR}10010030-${YEAR}12312330.nc -36.25,-20.25,0.0275 -65.25,-45.25,0.0275 bil

	echo
	echo "Merge files"
	CDO mergetime ${VAR}_E1hr_${EXP}_hindcast_r1i1p1f1_gn_${YEAR}*_lonlat.nc ${VAR}_${DOMAIN}_${EXP}_1hr_${YEAR}_lonlat.nc

    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
