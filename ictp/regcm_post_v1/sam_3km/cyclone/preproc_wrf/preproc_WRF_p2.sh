#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'May 28, 2024'
#__description__ = 'Posprocessing the WRF output with CDO'
 
{

# Change directory
PATH_NC="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/rcm_ii/wrf/preproc"
PATH_BIN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/rcm_ii/wrf/ncp"

mkdir ${PATH_BIN}

echo
echo "Running GrADS script to select"
echo ${PATH_NC}
   
grads -lbc "run preproc.gs ${PATH_NC} ${PATH_BIN}"

#ncdump -h ${arqnc} |grep "currently)"|awk -Fcurrently '{print $1}'|awk -F\( '{print $2}'

}
