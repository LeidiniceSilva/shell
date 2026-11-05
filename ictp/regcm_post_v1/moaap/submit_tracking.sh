#!/bin/bash

#SBATCH --account CMPNS_ictpclim
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH -t 12:00:00
#SBATCH -J Tracking
#SBATCH --ntasks-per-node=108
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH --qos=qos_lowprio

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 02, 2026'
#__description__ = 'Call tracking code'

{
set -eo pipefail

echo
echo "--------------- INIT TRACKING ----------------"

for year in `seq -w 2005 2009`; do
    python3 moaap_tracking_CPMs.py --inst CNRM --domain ALPX-3 --dataset CNRM-ESM2-1 --exp historical --DataName CNRM-ESM2-1_historical --year "${year}"
done

#python3 moaap_tracking_CPMs.py --inst CNRM --domain ALPX-3 --dataset ERA5 --exp evaluation --DataName ERA5_evaluation 

#python3 moaap_tracking_CPMs.py --inst ICTP --domain EURR-3 --dataset ERA5 --exp evaluation --DataName ERA5_evaluation 
#python3 moaap_tracking_RCMs.py --inst ICTP --domain EUR-12 --dataset ECEarth --exp ssp370 --DataName EC-Earth3-Veg_ssp370
#python3 moaap_tracking_RCMs.py --inst ICTP --domain EUR-12 --dataset ECEarth --exp historical --DataName EC-Earth3-Veg_historical 
#python3 moaap_tracking_RCMs.py --inst ICTP --domain EUR-12 --dataset ERA5 --exp evaluation --DataName ERA5_evaluation 

echo
echo "--------------- THE END TRACKING ----------------"

}
