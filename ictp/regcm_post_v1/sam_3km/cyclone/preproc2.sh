#!/bin/bash


#./preproc1.sh

pathnc="/home/aandrade/scratch/ECyclones/preproc/data/EUR1"
pathbin="/home/aandrade/scratch/ECyclones/preproc/data/NCPERA5_EUR"

      mkdir ${pathbin}


      echo
      echo "Running GrADS script to select"
      echo ${pathnc}
   
      grads -lbc "run preproc1_ERA5.gs ${pathnc} ${pathbin}"

      #ncdump -h ${arqnc} |grep "currently)"|awk -Fcurrently '{print $1}'|awk -F\( '{print $2}'
