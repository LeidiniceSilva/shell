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
#__date__        = 'Nov 20, 2023'
#__description__ = 'Posprocessing the OBS datasets with CDO'

{
source /leonardo/home/userexternal/ggiulian/modules_new
set -eo pipefail

bash postproc_cdo_obs_srf_p1.sh EOBS 2000-2000
bash postproc_cdo_obs_srf_p1.sh ERA5 2000-2000

bash postproc_cdo_obs_srf_p2.sh ERA5 2000-2000

bash postproc_cdo_obs_srf_p3.sh EOBS 2000-2000
bash postproc_cdo_obs_srf_p3.sh ERA5 2000-2000

bash postproc_cdo_obs_srf_p99.sh EOBS 2000-2000
bash postproc_cdo_obs_srf_p99.sh ERA5 2000-2000

bash postproc_cdo_obs_srf_freq_int.sh EOBS 2000-2000
bash postproc_cdo_obs_srf_freq_int.sh ERA5 2000-2000

bash postproc_cdo_obs_atm.sh ERA5 2000-2000

}
