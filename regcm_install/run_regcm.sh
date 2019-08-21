#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '12/11/18'
#__description__ = 'Instructions to run default RegCM'

# Run inside bin folder

# Processing to generate the contour conditions
./terrain regcm.in
./sst regcm.in
./icbc regcm.in

# Submit job  
qsub submeter_job1.sh

# mpirun -np 8 ./regcmMPI regcm.in

## To see the experiment execute: tail -f teste.log

### To see the experiment in queue run: qstat - C (Wrong), Q (Queue) and R (Run)





