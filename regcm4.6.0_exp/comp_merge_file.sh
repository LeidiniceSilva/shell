#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '11/19/2018'
#__description__ = 'Merge data file'



echo
echo "--------------- INIT ----------------"

for i in "psl" "tas" "pr"
do
  ncrcat `ls -al ${i}_Amon*.nc | awk '{printf $9" "}'` \
        ${i}_Amon_HadCM3_historical_r1i1p1_185912-200511.nc 
done

echo
echo "--------------- END ----------------"
