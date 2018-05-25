#!/bin/bash

#__author__ = 'Leidinice Silva'
#__email__  = 'leidinicesilva@gmail.br'
#__date__   = '05/14/18'

# Creating variables to analises with grads

cd /vol3/nice/output

for VAR in ATM RAD SRF STS; do 

    cdo cat amz_neb_${VAR}.*.nc amz_neb_${VAR}.2001010100_2005120100.nc

done	

