#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '12/11/18'
#__description__ = 'Instructions to install RegCM4.7'

# Unzip the folder
tar -zxvf RegCM-4.6.0.tar.gz

# Between in the folder
cd RegCM-4.6.0/

# Run
export FCFLAGS="-fconvert=big-endian -fno-range-check"

./configure FC="/usr/bin/gfortran" CC="/usr/bin/gcc" --with-netcdf=/usr

make check 

make install
