#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '06/11/19'
#__description__ = 'Instructions to run and submeter RegCM with CLM4.5'


# Run inside RegCM/bin folder
# Processing to generate the contour conditions

./terrainCLM45 regcm.in
./mksurfdataCLM45 regcm.in
./sstCLM45 regcm.in 
./icbcCLM45 regcm.in

# Submit job 

#SBATCH -J CFS # Job name
#SBATCH -o CFS.%j.out # Name of stdout output file (%j expands to %jobId)
#SBATCH -N 1  # Total number of nodes requested
#SBATCH -n 20 # Total number of mpi tasks #requested
#SBATCH -t 5000:00:00 # Run time (hh:mm:ss) - 1.5 hours

prun ./regcmMPICLM45 regcm.in > regcm.log

# To see in terminal: ps -aux | grep qrun
# To see in queue terminal: squeue C (Wrong), Q (Queue) and R (Run)
# To see the experiment execute: tail -f regcm.log or cat sbatch.out





