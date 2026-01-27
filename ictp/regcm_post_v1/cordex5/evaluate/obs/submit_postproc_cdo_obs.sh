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
#__description__ = 'Posprocessing the OBS datasets with CDO'

{
set -eo pipefail

bash postproc_cdo_obs_p1.sh CMORPH
bash postproc_cdo_obs_p1.sh CPC
bash postproc_cdo_obs_p1.sh CRU
bash postproc_cdo_obs_p1.sh ERA5
bash postproc_cdo_obs_p1.sh MSWEP

bash postproc_cdo_obs_p2.sh CMORPH
bash postproc_cdo_obs_p2.sh ERA5

bash postproc_cdo_obs_p99.sh CMORPH 
bash postproc_cdo_obs_p99.sh ERA5 
bash postproc_cdo_obs_p99.sh MSWEP

bash postproc_cdo_obs_p99_1hr.sh CMORPH 
bash postproc_cdo_obs_p99_1hr.sh ERA5 

bash postproc_cdo_obs_freq_int.sh CMORPH 
bash postproc_cdo_obs_freq_int.sh ERA5 
bash postproc_cdo_obs_freq_int.sh MSWEP

bash postproc_cdo_obs_freq_int_1hr.sh CMORPH 
bash postproc_cdo_obs_freq_int_1hr.sh ERA5 

bash postproc_cdo_obs_trend.sh

}
