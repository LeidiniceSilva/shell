#!/bin/bSPh

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

FREQ="1hr"
DOMAIN="CSAM-3"
MODEL="RegCM5-urb"
EXP="ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1"

YR="2000-2000"
IYR=$( echo $YR | cut -d- -f1 )
FYR=$( echo $YR | cut -d- -f2 )
SEASON_LIST="DJF MAM JJA SON"

VAR_LIST="sfcWind"
# VAR_LIST="hfls hfss sfcWind"

DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/urb"
BIN="/leonardo/home/userexternal/mdasilva/RegCM/bin"

echo
cd ${DIR_OUT}
echo ${DIR_OUT}

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

echo
echo "Select variable"
for VAR in ${VAR_LIST[@]}; do

    if [ ${MODEL} = 'RegCM5-urb' ]
    then
    DIR_IN="/leonardo/home/userexternal/ggiulian/scratch/urban/output/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/${FREQ}/${VAR}"
    else
    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/ERA5/ERA5-CSAM/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/${FREQ}/${VAR}"
    fi

    echo
    echo "Merge files"
    CDO mergetime ${DIR_IN}/${VAR}_${DOMAIN}_${EXP}_${FREQ}_2000*.nc ${VAR}_${DOMAIN}_${MODEL}_1hr_${YR}.nc
    CDO daymean ${VAR}_${DOMAIN}_${MODEL}_1hr_${YR}.nc ${VAR}_${DOMAIN}_${MODEL}_day_${YR}.nc
    CDO monmean ${VAR}_${DOMAIN}_${MODEL}_day_${YR}.nc ${VAR}_${DOMAIN}_${MODEL}_mon_${YR}.nc

    echo
    echo "Seasonal average"
    for SEASON in ${SEASON_LIST[@]}; do
	CDO -timmean -selseas,${SEASON} ${VAR}_${DOMAIN}_${MODEL}_mon_${YR}.nc ${VAR}_${DOMAIN}_${MODEL}_${SEASON}_${YR}.nc
    done
    
    CDO remapdis,grid_ctrl_sp.txt ${VAR}_${DOMAIN}_${MODEL}_mon_${YR}.nc ${VAR}_SP_${DOMAIN}_${MODEL}_mon_${YR}.nc
    CDO remapdis,grid_ctrl_ba.txt ${VAR}_${DOMAIN}_${MODEL}_mon_${YR}.nc ${VAR}_BA_${DOMAIN}_${MODEL}_mon_${YR}.nc

done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
