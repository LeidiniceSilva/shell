#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '12/11/18'
#__description__ = 'Process to submit experiment default RegCM'

#PBS -N <nice_exp1> ## Experiment name
#PBS -l nodes=1:ppn=2
#PBS -l walltime=100:00:00
#PBS -j oe

cd $PBS_O_WORKDIR

echo Running on host `hostname`
echo Time is `date`
echo Directory is `pwd`

cat $PBS_NODEFILE

NN=8 ## test NN=1, 2, 4 e 8

cd /users/nice/RegCM-4.6.0/bin

/usr/bin/mpiexec -np ${NN} -machinefile $PBS_NODEFILE ./regcmMPI regcm.in > teste.log


