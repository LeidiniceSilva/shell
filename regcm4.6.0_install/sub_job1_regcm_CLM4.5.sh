#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '12/11/18'
#__description__ = 'Process to submit experiment RegCM with CLM4.5'

#PBS -N <nice_CLM45_exp6> ## Experiment name
#PBS -l nodes=1:ppn=2
#PBS -l walltime=100:00:00
#PBS -j oe

cd $PBS_O_WORKDIR

echo Running on host `hostname`
echo Time is `date`
echo Directory is `pwd`

cat $PBS_NODEFILE

NN=8 ## Test NN=1, 2, 4 e 8

cd /users/nice/CLM4.5/RegCM-4.6.0/bin

/usr/bin/mpiexec -np ${NN} -machinefile $PBS_NODEFILE ./regcmMPICLM45 regcm_CLM45_exp6.in > teste_CLM45_exp6.log


