#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '05/29/20'
#__description__ = 'Instructions to run RegCM with CLM4.5'


# Run inside RegCM/bin folder
# Processing to generate the contour conditions

./terrainCLM45 exp_reg.in
./mksurfdataCLM45 exp_reg.in
./sstCLM45 exp_reg.in
./icbcCLM45 exp_reg.in

# Next step to submit expetiment
