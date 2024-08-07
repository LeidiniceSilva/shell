#!/bin/bash

#SBATCH -N 1 
#SBATCH -t 24:00:00
#SBATCH -A ICT23_ESP
#SBATCH --qos=qos_prio
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p skl_usr_prod

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jan 02, 2024'
#__description__ = 'Posprocessing the RegCM5 output with CDO'

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

echo
echo "--------------- INIT POSPROCESSING MODEL ----------------"

/marconi/home/userexternal/ggiulian/RegCM-5.0.0/bin/./sigma2pCLM45_SKL SAM_3km_cyclone_CP_RegCM5_ERA5.in SAM-3km-cyclone_ATM.2023060100_levs.nc

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

}
