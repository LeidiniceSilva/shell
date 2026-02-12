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
VAR_LIST="pr tas"

DIR_IN="/leonardo_work/ICT25_ESP/OBS/ERA5/daily"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/drought/obs"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

for VAR in ${VAR_LIST[@]}; do
    
    echo
    echo "Select variable"
    for YEAR in `seq -w ${IYR} ${FYR}`; do
        for MON in `seq -w 01 12`; do
	    ${BIN}/./regrid ${DIR_IN}/${VAR}_${YEAR}_${MON}_day.nc -35.70235,-11.25009,0.22 -78.66277,-35.48362,0.22 bil
        done
    done
    
    echo 
    echo "Concatenate date"
    CDO mergetime ${VAR}_*_day_lonlat.nc ${VAR}_${EXP}_ERA5_${YR}_lonlat.nc

    echo 
    echo "Convert variable"
    if [ ${VAR} = 'pr'  ]; then
    CDO -b f32 mulc,24000 ${VAR}_${EXP}_ERA5_${YR}_lonlat.nc ${VAR}_${EXP}_ERA5_day_${YR}_lonlat.nc
    else
    CDO -b f32 subc,273.15 ${VAR}_${EXP}_ERA5_${YR}_lonlat.nc ${VAR}_${EXP}_ERA5_day_${YR}_lonlat.nc
    fi
    CDO monmean ${VAR}_${EXP}_ERA5_day_${YR}_lonlat.nc ${VAR}_${EXP}_ERA5_mon_${YR}_lonlat.nc
 
    echo 
    echo "Delete files"
    rm ${VAR}_*_day_lonlat.nc
    rm ${VAR}_${EXP}_ERA5_${YR}_lonlat.nc

done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
