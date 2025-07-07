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

#python3 plot_maps_clim_srf.py --var pr
#python3 plot_maps_clim_srf.py --var tas
#python3 plot_maps_clim_srf.py --var clt

#python3 plot_maps_bias_srf.py --var pr
#python3 plot_maps_bias_srf.py --var tas
#python3 plot_maps_bias_srf.py --var clt

#python3 plot_maps_bias_srf_p99.py
#python3 plot_maps_bias_srf_int_freq.py --stats int
#python3 plot_maps_bias_srf_int_freq.py --stats freq

python3 plot_maps_clim_atm.py --var uv --level 200hPa
python3 plot_maps_clim_atm.py --var uv --level 500hPa
python3 plot_maps_clim_atm.py --var uv --level 850hPa

python3 plot_maps_clim_atm.py --var q --level 200hPa
python3 plot_maps_clim_atm.py --var q --level 500hPa
python3 plot_maps_clim_atm.py --var q --level 850hPa

#python3 plot_graph_pdf_daily.py
#python3 plot_graph_pdf_hourly.py

#python3 plot_graph_vertical_profile.py --var cl
#python3 plot_graph_vertical_profile.py --var clw
#python3 plot_graph_vertical_profile.py --var cli

echo
echo "--------------- THE END PLOT ----------------"

}

