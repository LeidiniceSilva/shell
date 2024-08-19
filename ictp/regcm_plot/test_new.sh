#!/bin/bash

#SBATCH -N 4
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

python3 plot_graph_pdf_precipitation_day-1hr.py

echo
echo "--------------- THE END PLOT ----------------"

}
