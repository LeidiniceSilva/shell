#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 15, 2024'
#__description__ = 'Postprocessing the dataset with CDO'

DATASET="ERA5"
DOMAIN_LIST="EAS"
#DOMAIN_LIST="AFR AUS CAM EAS EUR NAM SAM WAS"

for DOMAIN in ${DOMAIN_LIST[@]}; do

    # Change directory
    PATH_NC="/leonardo/home/userexternal/mdasilva/leonardo_work/TRACK-CYCLONE/CORDEX-TF/${DATASET}/S2R-Vortrack/${DOMAIN}/postproc"
    PATH_BIN="/leonardo/home/userexternal/mdasilva/leonardo_work/TRACK-CYCLONE/CORDEX-TF/${DATASET}/S2R-Vortrack/${DOMAIN}/ncp"
    mkdir ${PATH_BIN}

    echo
    echo "Running GrADS script to select"
    echo ${PATH_NC}
    grads -lbc "run preproc.gs ${PATH_NC} ${PATH_BIN}"

done
