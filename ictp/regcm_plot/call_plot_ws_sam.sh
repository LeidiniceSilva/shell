#!/bin/bash

#SBATCH -A CMPNS_ictpclim
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

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

echo
echo "--------------- INIT PLOT ----------------"

DIR_IN="/marconi/home/userexternal/mdasilva/github_projects/pypostdoc/ws-sa"
cd ${DIR_IN}

python3 plot_dendrogram_stations_sam_v2.py
python3 plot_cluster_stations_sam_v2.py

echo
echo "--------------- THE END PLOT ----------------"

}
