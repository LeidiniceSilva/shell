#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 15, 2024'
#__description__ = 'Preprocess RegCM5 output to track cyclone'

{

# Change directory
pathnc="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/rcm/track_p1"
pathbin="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/rcm/track_p2"

mkdir ${pathbin}

echo
echo "Running GrADS script to select"
echo ${pathnc}
   
grads -lbc "run preproc.gs ${pathnc} ${pathbin}"

#ncdump -h ${arqnc} |grep "currently)"|awk -Fcurrently '{print $1}'|awk -F\( '{print $2}'

}
