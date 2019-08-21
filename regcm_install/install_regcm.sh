#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '12/11/18'
#__description__ = 'Instructions to install RegCM4.7.1'

# Unzip the folder
tar -zxvf RegCM4.7.1.tar.gz

# Between in the folder
cd RegCM4.7.1/

# Run
export FCFLAGS="-fconvert=big-endian -fno-range-check"

# Configuration stage
# Deafault
./configure FC="/usr/bin/gfortran" CC="/usr/bin/gcc" --with-netcdf=/usr

make check 

make install
