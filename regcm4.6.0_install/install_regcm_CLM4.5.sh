#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '12/11/18'
#__description__ = 'Instructions to install CLM4.5 in RegCM'

# Unzip the folder
tar -zxvf RegCM-4.6.0.tar.gz

# Between in the folder
cd RegCM-4.6.0/

# Run
export FCFLAGS="-fconvert=big-endian -fno-range-check"

./configure --prefix=`pwd` FC="/usr/bin/gfortran" CC="/usr/bin/gcc" --with-netcdf=/usr --enable-clm45

make check

make install
