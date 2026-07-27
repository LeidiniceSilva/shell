#!/bin/bash

#SBATCH --account             ICT26_ESP
#SBATCH --job-name            Pycordexer
#SBATCH --mail-type           END,FAIL
#SBATCH --mail-user           mda_silv@ictp.it
#SBATCH --nodes               1
#SBATCH --ntasks-per-node     112
#SBATCH --partition           dcgp_usr_prod
#SBATCH --time                1-00:00:00

source $HOME/modules_new

/leonardo/home/userexternal/ggiulian/RegCM-CORDEX5/Tools/Scripts/pycordexer/pycordexer.py -m nchristi@ictp.it -d exp_senyar-4 -g ERA5 -e evaluation -b r1i1p1f1 -n None -o . --regcm-model-name RegCM -r 5.0 --regcm-version-id v1-r1 exp_senyar-4_ATM.2025112500.nc zq
