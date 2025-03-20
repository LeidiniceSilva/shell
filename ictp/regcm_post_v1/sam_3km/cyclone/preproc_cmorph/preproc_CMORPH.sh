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
#__description__ = 'Posprocessing the OBS datasets with CDO'

{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

EXP="SAM-3km"
DATASET="CMORPH"

YR="2018-2021"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS/CMORPH"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/cyclone/CMORPH"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING DATASET ----------------"

echo 
echo "Merge files"
FILE_IN=$( eval ls ${DIR_IN}/${DATASET}/cmorph_CSAM-3_CMORPH_1hr_{${IYR}..${FYR}}.nc )
FILE_OUT=cmorph_${EXP}_${DATASET}_1hr_${YR}.nc
[[ ! -f $FILE_OUT ]] && CDO -b f32 mergetime $FILE_IN $FILE_OUT
CDO daysum cmorph_${EXP}_${DATASET}_1hr_${YR}.nc cmorph_${EXP}_${DATASET}_day_${YR}.nc

echo 
echo "Regrid output"
${BIN}/./regrid cmorph_${EXP}_${DATASET}_1hr_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil	
${BIN}/./regrid cmorph_${EXP}_${DATASET}_day_${YR}.nc -35.70235,-11.25009,0.03 -78.66277,-35.48362,0.03 bil	

}
