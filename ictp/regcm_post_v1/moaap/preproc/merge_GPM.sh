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
#__description__ = 'Merge GPM IMERG & MERGIR '

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

DOMAIN_LIST=("CAR-4" "CSAM-3" "EURR-3")

for DOMAIN in "${DOMAIN_LIST[@]}"; do

    INFILE_II="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/GPM/CAR-4/preproc/pr_GPM_IMERG_CAR-4_1hr_200006.nc"
    INFILE_II="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/GPM/Tb_GPM_MERGIR_CAR-4_1hr_200006.nc"


    DIR_II="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/GPM"

    echo
    cd ${DIR_II}
    echo ${DIR_II}


OUTFILE="20000601_MOAAP-Input.nc"

# 1. Convert to curvilinear (creates 2D lat/lon and names dimensions y/x)
CDO -f nc4 -setgridtype,curvilinear $INFILE step1_2dgrid.nc

# 2. Convert 'Tb' from short to float (no renaming needed)
ncap2 -O -s 'Tb=float(Tb);' step1_2dgrid.nc step2_converted.nc

# 3. Apply attributes to 'pr' and set NaN fill values
ncatted -O \
  -a units,pr,m,c,"mm hr-1" \
  -a long_name,pr,m,c,"precipitation at surface" \
  -a cell_methods,pr,c,c,"time: sum" \
  -a _FillValue,pr,m,f,NaN \
  -a missing_value,pr,d,, \
  -a units,Tb,m,c,"K" \
  -a long_name,Tb,m,c,"brightness temperature" \
  -a cell_methods,Tb,c,c,"time: point" \
  -a _FillValue,Tb,m,f,NaN \
  -a missing_value,Tb,d,, \
  -a long_name,lat,m,c,"Latitudes, y-coordinate in Cartesian system" \
  -a _FillValue,lat,c,d,NaN \
  -a missing_value,lat,d,, \
  -a long_name,lon,m,c,"Longitudes, x-coordinate in Cartesian system" \
  -a _FillValue,lon,c,d,NaN \
  -a missing_value,lon,d,, \
  step2_converted.nc $OUTFILE

# Cleanup intermediate files
rm -f step1_2dgrid.nc step2_converted.nc

