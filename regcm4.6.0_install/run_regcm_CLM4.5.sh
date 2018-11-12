#!/bin/sh

## esses comandos devem ser executados na pasta "bin"

## processamento serial para gerar as condicoes de contorno
./terrainCLM45 regcm.in
./mksurfdataCLM45 regcm.in
./sstCLM45 regcm.in 
./icbcCLM45 regcm.in

qsub submeter_job1.sh

# mpirun -np 8 ./regcmMPICLM45 regcm.in

## para ver se deu certo

### tail -f teste.log

### qstat e olhar a "fila" (Queue) - se tiver C, deu errado, se der Q esta na fila, se der R esta rodando






