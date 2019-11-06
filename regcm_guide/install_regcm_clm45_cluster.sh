#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '06/11/19'
#__description__ = 'Instructions to install CLM4.5 in RegCM version 4.7.1'


# Download RegCM4.7.1
wget http://clima-dods.ictp.it/Users/ggiulian/RegCM-4.7.1.tar.gz

# Unzip the folder
tar -zxvf RegCM-4.7.1.tar.gz

# Between in the folder
cd RegCM4.7.1/
export FCFLAGS="fconvert=big-endian -fno-range-check"

# Loading libraries if necessary
# nedit .bashrc &
# module load netcdf-fortran/4.4.4
# module load netcdf/4.6.1
# module load openmpi3/3.1.0

# Configuration RegCM4.7.1 with CLM4.5
./configure --prefix=`pwd` --enable-clm45

# Install RegCM4.7.1 
make  
make install
