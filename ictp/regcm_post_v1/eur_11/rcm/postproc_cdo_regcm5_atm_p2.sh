#!/bin/bash

#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH -A ICT23_ESP_1
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p dcgp_usr_prod

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
VAR_LIST="cl cli clr cls clw hail hus gra ncc ncn ncr rh"
SEASON_LIST="DJF MAM JJA SON"
FOLDER_LIST="NoTo-Europe WDM7-Europe WSM7-Europe WSM5-Europe"

echo
echo "--------------- INIT POSTPROCESSING MODEL ----------------"

for FOLDER in ${FOLDER_LIST[@]}; do

    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/${FOLDER}"
    DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/EUR-11/postproc/rcm"
    BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

    echo
    cd ${DIR_OUT}
    echo ${DIR_OUT}

    for YEAR in `seq -w ${IYR} ${FYR}`; do
	for MON in `seq -w 01 12`; do

	    echo
            echo "2. Select variable"
	    for VAR in ${VAR_LIST[@]}; do               
		if [ ${VAR} = cl ]
		then
		CDO selname,${VAR} ${EXP}_RAD.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
		else
                CDO selname,${VAR} ${EXP}_ATM.${YEAR}${MON}0100.nc ${VAR}_${EXP}_${YEAR}${MON}0100.nc
		fi
	    done
	done
    done
    
        echo 
        echo "2. Concatenate data"
        CDO mergetime ${VAR}_${EXP}_*0100.nc ${VAR}_${EXP}_${FOLDER}_${YR}.nc
           
        echo
        echo "3. Convert unit"
        if [ ${VAR} = pr  ]
        then
        CDO -b f32 mulc,86400 ${VAR}_${EXP}_${FOLDER}_${YR}.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_day_${YR}.nc
        else
        CDO -b f32 subc,273.15 ${VAR}_${EXP}_${FOLDER}_${YR}.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_day_${YR}.nc
        fi

        echo
        echo "4. Seasonal avg and Regrid"
        for SEASON in ${SEASON_LIST[@]}; do
            CDO -timmean -selseas,${SEASON} ${VAR}_${EXP}_${FOLDER}_RegCM5_day_${YR}.nc ${VAR}_${EXP}_${FOLDER}_RegCM5_${SEASON}_${YR}.nc
	    ${BIN}/./regrid ${VAR}_${EXP}_${FOLDER}_RegCM5_${SEASON}_${YR}.nc 20.23606,70.85755,0.11 -42.69011,61.59245,0.11 bil
        done
    done
    
    echo 
    echo "5. Delete files"
    rm *0100.nc
    rm *${YR}.nc

done

echo
echo "--------------- THE END POSTPROCESSING MODEL ----------------"

}
