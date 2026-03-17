#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J JOB
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jan 27, 2026'
#__description__ = 'Call python code to compute Tb'

{
set -eo pipefail

echo
echo "--------------- INIT ----------------"

python3 compute_Tb.py

echo
echo "--------------- THE END ----------------"

}
