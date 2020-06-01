#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '05/29/20'
#__description__ = 'Instructions to run RegCM with CLM4.5'


# Run inside RegCM/bin folder
# Processing to generate the contour conditions

./terrainCLM45 exp_reg_hist.in
./mksurfdataCLM45 exp_reg_hist.in
./sstCLM45 exp_reg_hist.in
./icbcCLM45 exp_reg_hist.in

# Next step to submit expetiment
