#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '12/11/18'
#__description__ = 'Instructions to run RegCM with CLM4.5'

# Run inside bin folder

# Processing to generate the contour conditions
./terrainCLM45 regcm.in
./mksurfdataCLM45 regcm.in
./sstCLM45 regcm.in 
./icbcCLM45 regcm.in

# Submit job 
qsub submeter_job1.sh

# mpirun -np 8 ./regcmMPICLM45 regcm.in

## To see the experiment execute: tail -f teste.log

### To see the experiment in queue run: qstat - C (Wrong), Q (Queue) and R (Run)






