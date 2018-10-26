#!/bin/bash

#PBS -N <nice_CLM45_exp6>
#PBS -l nodes=1:ppn=2
#PBS -l walltime=100:00:00
#PBS -j oe

cd $PBS_O_WORKDIR

echo Running on host `hostname`
echo Time is `date`
echo Directory is `pwd`

cat $PBS_NODEFILE

NN=8 ## testar NN=1, 2, 4 e 8

cd /users/nice/CLM4.5/RegCM-4.6.0/bin

/usr/bin/mpiexec -np ${NN} -machinefile $PBS_NODEFILE ./regcmMPICLM45 regcm_CLM45_exp6.in > teste_CLM45_exp6.log


