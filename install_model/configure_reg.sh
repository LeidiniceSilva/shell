#!/bin/sh

wget https://gforge.ictp.it/gf/project/regcm/frs/RegCM-4.6.0.tar.gz

tar -zxvf RegCM-4.6.0.tar.gz

cd RegCM-4.6.0/

make clean 

export FCFLAGS="-fconvert=big-endian -fno-range-check"

./configure FC="/usr/bin/gfortran" CC="/usr/bin/gcc" --with-netcdf=/usr

make check 

make install
