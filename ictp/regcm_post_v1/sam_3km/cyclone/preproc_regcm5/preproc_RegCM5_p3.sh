#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 15, 2024'
#__description__ = 'Preprocess RegCM5 output to track cyclone'

{

# Change directory
PATH_NC="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/regcm5/postproc"
PATH_BIN="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/regcm5/ncp"

mkdir ${PATH_BIN}

echo
echo "Running GrADS script to select"
echo ${PATH_NC}
   
grads -lbc "run preproc.gs ${PATH_NC} ${PATH_BIN}"

#ncdump -h ${arqnc} |grep "currently)"|awk -Fcurrently '{print $1}'|awk -F\( '{print $2}'

}
