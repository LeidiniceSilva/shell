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
#__date__        = 'Jan 09, 2025'
#__description__ = 'Call python code to plot'

{
set -eo pipefail

echo
echo "--------------- INIT PLOT ----------------"

DIR_IN="/leonardo/home/userexternal/mdasilva/github_projects/pypostdoc/eur_11"
cd ${DIR_IN}

python3 plot_graph_pdf_hourly.py

echo
echo "--------------- THE END PLOT ----------------"

}

