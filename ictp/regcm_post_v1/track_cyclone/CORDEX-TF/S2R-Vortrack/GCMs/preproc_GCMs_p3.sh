#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 15, 2024'
#__description__ = 'Postprocessing the dataset with CDO'

GCM_LIST="CNRM-ESM2-1 EC-Earth3-Veg MPI-ESM1-2-HR" # CNRM-ESM2-1 EC-Earth3-Veg MPI-ESM1-2-HR NorESM-2MM
DOMAIN_LIST="AUS CAM EUR NAM SAM WAS"

for GCM in ${GCM_LIST[@]}; do
    for DOMAIN in ${DOMAIN_LIST[@]}; do

        # Change directory
        PATH_NC="/leonardo/home/userexternal/mdasilva/leonardo_work/TRACK-CYCLONE/CORDEX-TF/${GCM}/S2R-Vortrack/${DOMAIN}/postproc"
        PATH_BIN="/leonardo/home/userexternal/mdasilva/leonardo_work/TRACK-CYCLONE/CORDEX-TF/${GCM}/S2R-Vortrack/${DOMAIN}/ncp"
        mkdir ${PATH_BIN}

        echo
        echo "Running GrADS script to select"
        echo ${PATH_NC}
       	grads -lbc "run preproc.gs ${PATH_NC} ${PATH_BIN}"

    done
done
