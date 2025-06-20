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

DIR_IN="/leonardo/home/userexternal/mdasilva/github_projects/pypostdoc/sam_22"
cd ${DIR_IN}

EXP="pbl_RegCM5"

python3 plot_maps_clim_atm.py --var uv --level 200hPa --exp_i ctrl_RegCM5 --exp_ii ${EXP}
python3 plot_maps_clim_atm.py --var uv --level 500hPa --exp_i ctrl_RegCM5 --exp_ii ${EXP}
python3 plot_maps_clim_atm.py --var uv --level 850hPa --exp_i ctrl_RegCM5 --exp_ii ${EXP}

python3 plot_maps_clim_atm.py --var q --level 200hPa --exp_i ctrl_RegCM5 --exp_ii ${EXP}
python3 plot_maps_clim_atm.py --var q --level 500hPa --exp_i ctrl_RegCM5 --exp_ii ${EXP}
python3 plot_maps_clim_atm.py --var q --level 850hPa --exp_i ctrl_RegCM5 --exp_ii ${EXP}

python3 plot_maps_bias_atm.py --var uv --level 200hPa --exp_i ctrl_RegCM5 --exp_ii ${EXP}
python3 plot_maps_bias_atm.py --var uv --level 500hPa --exp_i ctrl_RegCM5 --exp_ii ${EXP}
python3 plot_maps_bias_atm.py --var uv --level 850hPa --exp_i ctrl_RegCM5 --exp_ii ${EXP}

python3 plot_maps_bias_atm.py --var q --level 200hPa --exp_i ctrl_RegCM5 --exp_ii ${EXP}
python3 plot_maps_bias_atm.py --var q --level 500hPa --exp_i ctrl_RegCM5 --exp_ii ${EXP}
python3 plot_maps_bias_atm.py --var q --level 850hPa --exp_i ctrl_RegCM5 --exp_ii ${EXP}

echo
echo "--------------- THE END PLOT ----------------"

}

