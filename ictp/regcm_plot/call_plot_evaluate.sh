#!/bin/bash

#SBATCH -A ICT25_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Plot
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 04, 2024'
#__description__ = 'Call python code to plot'

{

source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

echo
echo "--------------- INIT PLOT ----------------"

DIR_IN="/leonardo/home/userexternal/mdasilva/github_projects/pypostdoc/sam_3km/evaluate"
cd ${DIR_IN}

python3 plot_graph_annual_cycle.py
python3 plot_graph_pdf_function.py
python3 plot_graph_pdf_function_1hr.py

echo
echo "--------------- THE END PLOT ----------------"

}
