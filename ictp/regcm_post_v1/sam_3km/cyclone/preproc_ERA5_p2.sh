#!/bin/bash

#SBATCH -J preproctrack
#SBATCH -t 24:00:00
#SBATCH -A ICT23_ESP
#SBATCH --qos=qos_prio
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mda_silv@ictp.it
#SBATCH -p skl_usr_prod
#SBATCH -N 1 --ntasks-per-node=20

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 15, 2024'
#__description__ = 'Preprocess RegCM5 output to track cyclone'

# Change directory
pathnc="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/obs/track_p1"
pathbin="/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/post_cyclone/obs/track_p2"

mkdir ${pathbin}

echo
echo "Running GrADS script to select"
echo ${pathnc}
   
grads -lbc "run preproc.gs ${pathnc} ${pathbin}"

#ncdump -h ${arqnc} |grep "currently)"|awk -Fcurrently '{print $1}'|awk -F\( '{print $2}'
