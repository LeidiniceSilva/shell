#!/bin/bash

#SBATCH -A ICT23_ESP_1
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

FREQ="day"
DOMAIN="CSAM-3"

YR="2000-2000"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

VAR_LIST="pr tas tasmax tasmin rsnl rsns cll clm clh clt evspsblpot"

DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/ERA5/ERA5-CSAM-3"
DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/rcm"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

is_leap_year() {
    YEAR=$1
    if [ $((YEAR % 4)) -eq 0 ]
    then
        if [ $((YEAR % 100)) -ne 0 ] || [ $((YEAR % 400)) -eq 0 ]; then
            return 0 # Leap year
        else
            return 1 # Not a leap year
        fi
    else
        return 1     # Not a leap year
    fi
}

echo
echo "Select variable"
for VAR in ${VAR_LIST[@]}; do
    for YEAR in `seq -w ${IYR} ${FYR}`; do
        for MON in `seq -w 01 12`; do
	    case ${MON} in
		01|03|05|07|08|10|12)
		    DAYS=31
		    ;;
		04|06|09|11)
		    DAYS=30
		    ;;
		02)
		    if is_leap_year ${YEAR}
		    then
			DAYS=29
		    else
			DAYS=28
		    fi
		    ;;
	    esac
	    for DAY in `seq -w 01 ${DAYS}`; do
		if [ ${VAR} = 'pr'  ] || [ ${VAR} = 'tas'  ] || [ ${VAR} = 'tasmax'  ] || [ ${VAR} = 'tasmin'  ] 
		then
		CDO selname,${VAR} ${DIR_IN}/CSAM-3_STS.${YEAR}${MON}${DAY}00.nc ${VAR}_${DOMAIN}_${YEAR}${MON}${DAY}.nc
		elif [ ${VAR} = 'rsnl'  ] || [ ${VAR} = 'rsns'  ] || [ ${VAR} = 'cll'  ] || [ ${VAR} = 'clm'  ] || [ ${VAR} = 'clh' ]
		then
		CDO selname,${VAR} ${DIR_IN}/CSAM-3_RAD.${YEAR}${MON}${DAY}00.nc ${VAR}_${DOMAIN}_${YEAR}${MON}${DAY}.nc
		else
		CDO selname,${VAR} ${DIR_IN}/CSAM-3_SRF.${YEAR}${MON}${DAY}00.nc ${VAR}_${DOMAIN}_${YEAR}${MON}${DAY}.nc
		fi
	    done
	done
    done

    echo
    echo "Merge files"
    CDO mergetime ${VAR}_${DOMAIN}_*.nc ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc

    echo
    echo "Convert unit"
    if [ ${VAR} = 'pr'  ]
    then
    CDO -b f32 mulc,86400 ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_day_${YR}.nc
    CDO monmean ${VAR}_${DOMAIN}_RegCM5_day_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc
    ${BIN}/./regrid ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    elif [ ${VAR} = 'evspsblpot'  ]
    then
    CDO -b f32 mulc,3600 ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_${YR}.nc
    CDO daysum ${VAR}_${DOMAIN}_RegCM5_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_day_${YR}.nc 
    CDO monmean ${VAR}_${DOMAIN}_RegCM5_day_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc
    ${BIN}/./regrid ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    elif [ ${VAR} = 'tas' ] || [ ${VAR} = 'tasmax'  ] || [ ${VAR} = 'tasmin'  ]
    then
    CDO -b f32 subc,273.15 ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_day_${YR}.nc
    CDO monmean ${VAR}_${DOMAIN}_RegCM5_day_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc
    ${BIN}/./regrid ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    else
    CDO monmean ${VAR}_${DOMAIN}_${EXP}_${FREQ}_${YR}.nc ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc
    ${BIN}/./regrid ${VAR}_${DOMAIN}_RegCM5_mon_${YR}.nc -36.70233,-12.24439,0.03 -78.81965,-35.32753,0.03 bil
    fi

    echo
    echo "Seasonal avg and regrid"
    for SEASON in ${SEASON_LIST[@]}; do
	CDO -timmean -selseas,${SEASON} ${VAR}_${DOMAIN}_RegCM5_mon_${YR}_lonlat.nc ${VAR}_${DOMAIN}_RegCM5_${SEASON}_${YR}_lonlat.nc
    done
    
    echo 
    echo "Delete files"
    rm ${VAR}_${DOMAIN}_${EXP}_${FREQ}_*.nc
    rm ${VAR}_${DOMAIN}_*_${YR}.nc
      
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
