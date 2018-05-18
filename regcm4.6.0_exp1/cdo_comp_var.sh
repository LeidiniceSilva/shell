#!/bin/bash

#__author__ = 'Leidinice Silva'
#__email__  = 'leidinicesilva@gmail.br'
#__date__   = '05/14/18'

# Creating variables to analises with grads


for VAR in ATM RAD SRF STS; do 

    cdo cat *.ctl amz_neb_${VAR}.2001010100_2005120100.nc.ctl

done	

#cdo selname,xxxx amz_neb_${VAR}.2001010100_2005120100.nc.ctl amz_neb_xxxx.2001010100_2005120100.nc.ctl
#cdo selname,xxxx amz_neb_${VAR}.2001010100_2005120100.nc.ctl amz_neb_xxxx.2001010100_2005120100.nc.ctl
#cdo selname,xxxx amz_neb_${VAR}.2001010100_2005120100.nc.ctl amz_neb_xxxx.2001010100_2005120100.nc.ctl
#cdo selname,xxxx amz_neb_${VAR}.2001010100_2005120100.nc.ctl amz_neb_xxxx.2001010100_2005120100.nc.ctl

