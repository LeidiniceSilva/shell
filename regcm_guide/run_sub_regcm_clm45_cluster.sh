#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '06/11/19'
#__description__ = 'Instructions to run and submeter RegCM with CLM4.5'

if test -f $PATH; then
	echo "ICBC already was run"

	# Submit job 
	#SBATCH -J RegHad_AMZ_NEB # Job name
	#SBATCH -o RegHad_AMZ_NEB.%j.out # Name of stdout output file (%j expands to %jobId)
	#SBATCH -N 1  # Total number of nodes requested
	#SBATCH -n 20 # Total number of mpi tasks #requested
	#SBATCH -t 5000:00:00 # Run time (hh:mm:ss) - 1.5 hours

prun ./regcmMPICLM45 regcm.in > regcm.log

else
	echo "Run ICBC and submeter experiment"
	# Run inside bin folder
	# Processing to generate the contour conditions
	./terrainCLM45 regcm.in
	./mksurfdataCLM45 regcm.in
	./sstCLM45 regcm.in 
	./icbcCLM45 regcm.in

	# Submit job 
	#SBATCH -J RegHad_AMZ_NEB # Job name
	#SBATCH -o RegHad_AMZ_NEB.%j.out # Name of stdout output file (%j expands to %jobId)
	#SBATCH -N 1  # Total number of nodes requested
	#SBATCH -n 20 # Total number of mpi tasks #requested
	#SBATCH -t 5000:00:00 # Run time (hh:mm:ss) - 1.5 hours

	prun ./regcmMPICLM45 regcm.in > regcm.log

fi

exit

# To see in terminal: ps -aux | grep qrun
# To see in queue terminal: squeue C (Wrong), Q (Queue) and R (Run)
# To see the experiment execute: tail -f regcm.log or cat sbatch.out





