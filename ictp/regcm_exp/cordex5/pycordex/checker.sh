#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J CHNAME
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

compliance-checker -t wcrp_cordex_cmip6:1.0 /leonardo_work/ICT26_ESP/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1/1hr/cape/v20260622/cape_CSAM-3_ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1_1hr_200001010100-200101010000.nc
