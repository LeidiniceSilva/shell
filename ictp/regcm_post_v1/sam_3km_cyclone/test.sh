#!/bin/bash

#SBATCH -N 1 
#SBATCH -t 24:00:00
#SBATCH -A ICT23_ESP
#SBATCH --qos=qos_prio
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p skl_usr_prod

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jun 10, 2024'
#__description__ = 'Post-processing GPM'

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

dir_out=/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/obs/gpm

cdo mergetime $dir_out/precipitation_SAM_GPM_3B-HHR_2018*_V07A.nc $dir_out/precipitation_SAM_GPM_3B-HHR_2018.nc
cdo mergetime $dir_out/precipitation_SAM_GPM_3B-HHR_2019*_V07A.nc $dir_out/precipitation_SAM_GPM_3B-HHR_2019.nc
cdo mergetime $dir_out/precipitation_SAM_GPM_3B-HHR_2020*_V07A.nc $dir_out/precipitation_SAM_GPM_3B-HHR_2020.nc
cdo mergetime $dir_out/precipitation_SAM_GPM_3B-HHR_2021*_V07A.nc $dir_out/precipitation_SAM_GPM_3B-HHR_2021.nc

}
