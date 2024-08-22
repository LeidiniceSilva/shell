#!/bin/bash

#SBATCH -N 8
#SBATCH -t 24:00:00
#SBATCH -A ICT23_ESP
#SBATCH --qos=qos_prio
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p skl_usr_prod

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 04, 2024'
#__description__ = 'Call python code to plot'

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

echo
echo "--------------- INIT PLOT ----------------"

DIR_IN="/marconi/home/userexternal/mdasilva/github_projects/pypostdoc/sam_3km/sam_3km_cyclone/paper"
cd ${DIR_IN}

python3 /marconi/home/userexternal/ggiulian/pycordexer/pycordexer.py /marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km-cyclone/output/SAM-3km-cyclone_ATM.2023060100.nc capecin

echo
echo "--------------- THE END PLOT ----------------"

}
