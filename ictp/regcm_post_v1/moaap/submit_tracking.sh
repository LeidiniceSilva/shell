#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J MOAAP
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 02, 2026'
#__description__ = 'Call tracking code'

{
set -eo pipefail

echo
echo "--------------- INIT TRACKING ----------------"

python3 /leonardo/home/userexternal/mdasilva/github_projects/pypostdoc/moaap/moaap_tracking.py

echo
echo "--------------- THE END TRACKING ----------------"

}
