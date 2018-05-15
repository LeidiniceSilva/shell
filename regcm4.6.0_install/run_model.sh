## esses comandos devem ser executados na pasta "bin"

## processamento serial para gerar as condicoes de contorno
./terrain regcm.in
./sst regcm.in
./icbc regcm.in

## processamento paralelo para o modelo 

qsub submeter_job1.sh


## para ver se deu certo

### tail -f teste.log

### qstat e olhar a "fila" (Queue) - se tiver C, deu errado, se der Q esta na fila, se der R esta rodando





