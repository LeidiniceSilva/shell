#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '12/11/18'
#__description__ = 'Instructions to install CLM4.5 in RegCM version 4.7.1'

# Unzip the folder
tar -zxvf RegCM-4.7.1.tar.gz

# Between in the folder
cd RegCM4.7.1/

# Run
export FCFLAGS="-fconvert=big-endian -fno-range-check"

# Configuration stage
# CLM4.5
./configure --prefix=`pwd` FC="/usr/bin/gfortran" CC="/usr/bin/gcc" --with-netcdf=/usr --enable-clm45

make check 

make install
