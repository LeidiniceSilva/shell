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

DOMAIN="CSAM-3"
EXP="ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1"

YR="2000-2009"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"
VAR_LIST="pr tas tasmax tasmin cll clm clh clt evspsblpot rlds cape cin"

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/evaluate/rcm"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "Select variable"
for VAR in ${VAR_LIST[@]}; do

    if [ ${VAR} = 'evspsblpot' ]
    then
        FREQ="1hr"
    else
        FREQ="day"
    fi

    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/ERA5/ERA5-CSAM/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/${FREQ}/${VAR}"

    echo
    echo "Merge files"
    CDO mergetime ${DIR_IN}/${VAR}_${DOMAIN}_${EXP}_${FREQ}_*.nc ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc

    echo
    echo "Convert unit"
    if [ ${VAR} = 'pr'  ]
    then
    CDO -b f32 mulc,86400 ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_day_${YR}.nc
    CDO monmean ${VAR}_${DOMAIN}_RegCM5_day_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc
    ${BIN}/./regrid ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    elif [ ${VAR} = 'tas' ] || [ ${VAR} = 'tasmax'  ] || [ ${VAR} = 'tasmin'  ]
    then
    CDO -b f32 subc,273.15 ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_day_${YR}.nc
    CDO monmean ${VAR}_${DOMAIN}_RegCM5_day_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc
    ${BIN}/./regrid ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    elif [ ${VAR} = 'clt'  ] || [ ${VAR} = 'cll'  ] || [ ${VAR} = 'clm'  ] || [ ${VAR} = 'clh'  ]
    then
    CDO -b f32 divc,100 ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_day_${YR}.nc
    CDO monmean ${VAR}_${DOMAIN}_RegCM5_day_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc
    ${BIN}/./regrid ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    elif [ ${VAR} = 'evspsblpot'  ]
    then
    CDO -b f32 mulc,3600 ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_${FREQ}_${YR}.nc
    CDO daysum ${VAR}_${DOMAIN}_RegCM5_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_day_${YR}.nc
    CDO monmean ${VAR}_${DOMAIN}_RegCM5_day_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc
    ${BIN}/./regrid ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    else
    CDO monmean ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc
    ${BIN}/./regrid ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    fi

    echo
    echo "Seasonal avg"
    for SEASON in ${SEASON_LIST[@]}; do
	CDO -timmean -selseas,${SEASON} ${VAR}_${DOMAIN}_RegCM5_mon_${YR}_lonlat.nc ${VAR}_${DOMAIN}_RegCM5_${SEASON}_${YR}_lonlat.nc
    done
    
    echo 
    echo "Delete files"
    rm ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc
    rm ${VAR}_${DOMAIN}_RegCM5_day_${YR}.nc
    rm ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc
      
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
