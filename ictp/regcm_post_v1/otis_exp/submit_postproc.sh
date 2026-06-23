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
#__date__        = 'Sept 24, 2025'
#__description__ = 'Call postproc code'

{
set -eo pipefail

echo
echo "--------------- INIT POSTPROC ----------------"

bash postproc_cdo_regcm5_atm.sh exps_v1 2023101900
bash postproc_cdo_regcm5_srf.sh exps_v1 2023101900 
bash sfcWind.sh exps_v1 large 2023101900
bash regrid.sh exps_v1 large   

echo
echo "--------------- THE END POSTPROC ----------------"

}
