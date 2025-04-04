#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 15, 2024'
#__description__ = 'Postprocessing the RegCM5 output with CDO'

{

# Change directory
PATH_NC="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/cyclone/RegCM5"
PATH_BIN="/leonardo/home/userexternal/mdasilva/leonardo_work/SAM-3km/postproc/cyclone/RegCM5/ncp"

mkdir ${PATH_BIN}

echo
echo "Running GrADS script to select"
echo ${PATH_NC}
   
grads -lbc "run preproc.gs ${PATH_NC} ${PATH_BIN}"

#ncdump -h ${arqnc} |grep "currently)"|awk -Fcurrently '{print $1}'|awk -F\( '{print $2}'

}
