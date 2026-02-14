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
#__date__        = 'Jan 10, 2026'
#__description__ = 'Posprocessing the OBS with CDO'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

YR="2018-2021"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )

EXP="SAM-3km"
VAR_LIST="avg_ishf"
#VAR_LIST="avg_slhtf avg_ishf avg_snlwrf avg_snswrf mn2t mx2t"

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/drought/obs"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do

    CDO mergetime ${VAR}_ERA5_*.nc ${VAR}_${EXP}_ERA5_day_${YR}.nc
    ${BIN}/./regrid ${VAR}_${EXP}_ERA5_day_${YR}.nc -35.70235,-11.25009,0.22 -78.66277,-35.48362,0.22 bil    
   
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
