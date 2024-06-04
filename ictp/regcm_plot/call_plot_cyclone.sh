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
#__date__        = 'Mar 04, 2024'
#__description__ = 'Call python code to plot'

{

echo
echo "--------------- INIT PLOT ----------------"

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

DIR_IN="/marconi/home/userexternal/mdasilva/github_projects/pypostdoc/sam_3km/sam_3km_cyclone"
cd ${DIR_IN}
python3 plot_graph_pdf_precipitation_acc_ec.py

echo
echo "--------------- THE END PLOT ----------------"

}
