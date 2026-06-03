#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jan 20, 2026'
#__description__ = 'Posprocessing the RegCM with CDO'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DOMAIN=$1  # CAR-4 CSAM-3 EURR-3
EXP="ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1"

if [ ${DOMAIN} = 'CAR-4'  ]; then
	DIR_I="/leonardo_work/ICT26_ESP/jdeleeuw/CAR-4/ERA5/high_soil_moisture_OCN/ERA5/CAR-4/postproc/CORDEX-CMIP6/DD/CAR-4/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr"
elif [ ${DOMAIN} = 'CSAM-3'  ]; then
	DIR_I="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/ERA5/ERA5-CSAM-3/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr"
elif [ ${DOMAIN} = 'EURR-3'  ]; then
	DIR_I="/leonardo_work/ICT26_ESP/jdeleeuw/EURR-3/ERA5/high_soil_moisture/ERA5/EURR-3/postproc/CORDEX-CMIP6/DD/EURR-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/pr"
else
	echo "Error: Unknown DOMAIN = ${DOMAIN}"
	exit 1
fi	

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

# Part I
DIR_II="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/CPMs/historical/${DOMAIN}/preproc"

CDO mergetime ${DIR_I}/pr_* ${DIR_II}/pr_${DOMAIN}_${EXP}_mmhr_2000-2009.nc
CDO mulc,3600 ${DIR_II}/pr_${DOMAIN}_${EXP}_mmhr_2000-2009.nc ${DIR_II}/pr_${DOMAIN}_${EXP}_1hr_2000-2009.nc
rm ${DIR_II}/pr_${DOMAIN}_${EXP}_mmhr_2000-2009.nc

CDO mergetime ${DIR_II}/Tb/Tb_* ${DIR_II}/Tb_${DOMAIN}_${EXP}_1hr_2000-2009.nc

# Part II
DIR_III="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/CPMs/historical/${DOMAIN}/input"

YEARS=$(seq 2000 2009)
for YEAR in $YEARS; do
    for MON in $(seq -w 1 12); do

	echo "Processing ${YEAR} ${MON}"

        FILE_OUT_I=pr_${DOMAIN}_${EXP}_1hr_${YEAR}${MON}0100.nc
        FILE_OUT_II=Tb_${DOMAIN}_${EXP}_1hr_${YEAR}${MON}0100.nc
        FILE_OUT_III=${DOMAIN}_${EXP}_1hr_${YEAR}${MON}0100.nc
        FILE_OUT_IV=${DOMAIN}_${EXP}_1hr_${YEAR}${MON}0100_regrid.nc

        CDO seldate,${YEAR}-${MON}-01,${YEAR}-${MON}-31 ${DIR_II}/pr_${DOMAIN}_${EXP}_1hr_2000-2009.nc ${DIR_III}/$FILE_OUT_I
        CDO seldate,${YEAR}-${MON}-01,${YEAR}-${MON}-31 ${DIR_II}/Tb_${DOMAIN}_${EXP}_1hr_2000-2009.nc ${DIR_III}/$FILE_OUT_II
        CDO merge ${DIR_III}/$FILE_OUT_I ${DIR_III}/$FILE_OUT_II ${DIR_III}/$FILE_OUT_III

        CDO remapbil,/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/CPMs/historical/${DOMAIN}/grid.txt ${DIR_III}/$FILE_OUT_III ${DIR_III}/$FILE_OUT_IV

	echo "Processed $DIR_OUT_III"

    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}

