#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 04, 2024'
#__description__ = 'Post-processing WRF output'

year=2018

for mon in {01..12}; do

    cdo selvar,P wrf3d_ml_saag_${year}${mon}.nc P_wrf3d_ml_saag_${year}${mon}.nc
    cdo selvar,Z wrf3d_ml_saag_${year}${mon}.nc Z_wrf3d_ml_saag_${year}${mon}.nc
    cdo selvar,TK wrf3d_ml_saag_${year}${mon}.nc TK_wrf3d_ml_saag_${year}${mon}.nc

done

