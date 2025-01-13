#!/bin/bash

#SBATCH -N 1
#SBATCH -t 24:00:00
#SBATCH -J Testing
#SBATCH -p long # esp
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jan 09, 2025'
#__description__ = 'Call python code to plot'

{

# load required modules
module purge
source /opt-ictp/ESMF/env202108

echo
echo "--------------- INIT PLOT ----------------"

python3 test.py

echo
echo "--------------- THE END PLOT ----------------"

}

