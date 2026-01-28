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
#__date__        = 'Jan 27, 2026'
#__description__ = 'Call python code to plot'

{
set -eo pipefail

echo
echo "--------------- INIT PLOT ----------------"

DIR_IN="/leonardo/home/userexternal/mdasilva/github_projects/pypostdoc/cordex5/evaluate"
cd ${DIR_IN}

#for varc in pr tas tasmax tasmin clt cll clm clh evspsblpot rlds cape cin; do
#    python3 plot_maps_clim_srf.py --var "${varc}" --domain CSAM-3 --idt 2000 --fdt 2009
#done

#for varb in pr tas tasmax tasmin clt cll clm clh evspsblpot rlds; do
#    python3 plot_maps_bias_srf.py --var "${varb}" --domain CSAM-3 --idt 2000 --fdt 2009
#done

python3 plot_maps_bias_srf_p99.py --var p99 --freq daily --domain CSAM-3 --idt 2000 --fdt 2009
#python3 plot_maps_bias_srf_p99.py --var p99 --freq hourly --domain CSAM-3 --idt 2000 --fdt 2009

python3 plot_maps_bias_srf_freq_int.py --var pr --stats int --freq daily --domain CSAM-3 --idt 2000 --fdt 2009
python3 plot_maps_bias_srf_freq_int.py --var pr --stats freq --freq daily --domain CSAM-3 --idt 2000 --fdt 2009
#python3 plot_maps_bias_srf_freq_int.py --var pr --stats int --freq hourly --domain CSAM-3 --idt 2000 --fdt 2009
#python3 plot_maps_bias_srf_freq_int.py --var pr --stats freq --freq hourly --domain CSAM-3 --idt 2000 --fdt 2009

python3 plot_maps_trend_srf.py --var pr --domain CSAM-3 --idt 2000 --fdt 2009
python3 plot_maps_trend_srf.py --var tas --domain CSAM-3 --idt 2000 --fdt 2009
python3 plot_maps_trend_srf.py --var tasmax --domain CSAM-3 --idt 2000 --fdt 2009
python3 plot_maps_trend_srf.py --var tasmin --domain CSAM-3 --idt 2000 --fdt 2009

echo
echo "--------------- THE END PLOT ----------------"

}
