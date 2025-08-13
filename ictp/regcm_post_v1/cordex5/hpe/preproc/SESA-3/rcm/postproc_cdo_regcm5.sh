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
EXP="CORDEX-RegCM5"
DOMAINS="CSAM-3" # EURR-3
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

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
for DOMAIN in ${DOMAINS[@]}; do

    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/ERA5/ERA5-${DOMAIN}"

    if [ ${DOMAIN} == 'CSAM-3' ]
    then
    DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/hpe/input/SESA-3/RegCM5"
    else
    DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/hpe/input/ALP-3/RegCM5"
    fi

    cd ${DIR_OUT}
    echo ${DIR_OUT}

    for YEAR in `seq -w 2000 2009`; do
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

		CDO selname,${VAR} ${DIR_IN}/${DOMAIN}_SRF.${YEAR}${MON}${DAY}00.nc ${VAR}_${DOMAIN}_${YEAR}${MON}${DAY}.nc
		CDO -b f32 mulc,3600 ${VAR}_${DOMAIN}_${YEAR}${MON}${DAY}.nc ${VAR}_${DOMAIN}_${EXP}_${YEAR}${MON}${DAY}.nc

		if [ ${DOMAIN} == 'CSAM-3' ]
		then
		${BIN}/./regrid ${VAR}_${DOMAIN}_${EXP}_${YEAR}${MON}${DAY}.nc -36.25,-20.25,0.0275 -65.25,-45.25,0.0275 bil
		else
		${BIN}/./regrid ${VAR}_${DOMAIN}_${EXP}_${YEAR}${MON}${DAY}.nc 40,50,0.0275 1,17,0.0275 bil
		fi

	    done
	done

    	echo
   	echo "Merge files"
	if [ ${DOMAIN} == 'CSAM-3' ]
	then
    	CDO mergetime ${VAR}_${DOMAIN}_${EXP}_${YEAR}*_lonlat.nc ${VAR}_SESA-3_${EXP}_1hr_${YEAR}_lonlat.nc
	else
    	CDO mergetime ${VAR}_${DOMAIN}_${EXP}_${YEAR}*_lonlat.nc ${VAR}_ALP-3_${EXP}_1hr_${YEAR}_lonlat.nc
	fi

    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
