#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '02/01/2023'
#__description__ = 'Compute field correlation of RegCM46 exps with CDO'
 
echo
echo "--------------- INIT POSPROCESSING ----------------"

OBS="cmorph_v1_obs"
SIM="regcm_exp2"
DATE="2001-2005"
AREA="neb"

# Season list
SEA_LIST=('djf' 'jja' 'ann')    

for SEA in ${SEA_LIST[@]}; do

    DIR_OBS="/home/nice/Documentos/dataset/obs/reg_pbl/"
    DIR_SIM="/home/nice/Documentos/dataset/rcm/reg_pbl/"

    cdo fldcor ${DIR_OBS}pr_${AREA}_${OBS}_${SEA}_${DATE}.nc ${DIR_SIM}pr_${AREA}_${SIM}_${SEA}_${DATE}.nc fdlcor_pr_${AREA}_${SIM}_${SEA}_${DATE}.nc
    cdo timmean fdlcor_pr_${AREA}_${SIM}_${SEA}_${DATE}.nc ${AREA}_${SIM}_${SEA}_${DATE}_fdlcor_pr.nc

done

cdo infon namz_regcm_exp1_djf_2001-2005_fdlcor_pr.nc
cdo infon samz_regcm_exp1_djf_2001-2005_fdlcor_pr.nc
cdo infon neb_regcm_exp1_djf_2001-2005_fdlcor_pr.nc
cdo infon namz_regcm_exp2_djf_2001-2005_fdlcor_pr.nc
cdo infon samz_regcm_exp2_djf_2001-2005_fdlcor_pr.nc
cdo infon neb_regcm_exp2_djf_2001-2005_fdlcor_pr.nc

cdo infon namz_regcm_exp1_jja_2001-2005_fdlcor_pr.nc
cdo infon samz_regcm_exp1_jja_2001-2005_fdlcor_pr.nc
cdo infon neb_regcm_exp1_jja_2001-2005_fdlcor_pr.nc
cdo infon namz_regcm_exp2_jja_2001-2005_fdlcor_pr.nc
cdo infon samz_regcm_exp2_jja_2001-2005_fdlcor_pr.nc
cdo infon neb_regcm_exp2_jja_2001-2005_fdlcor_pr.nc

cdo infon namz_regcm_exp1_ann_2001-2005_fdlcor_pr.nc
cdo infon samz_regcm_exp1_ann_2001-2005_fdlcor_pr.nc
cdo infon neb_regcm_exp1_ann_2001-2005_fdlcor_pr.nc
cdo infon namz_regcm_exp2_ann_2001-2005_fdlcor_pr.nc
cdo infon samz_regcm_exp2_ann_2001-2005_fdlcor_pr.nc
cdo infon neb_regcm_exp2_ann_2001-2005_fdlcor_pr.nc

echo
echo "--------------- THE END POSPROCESSING ----------------"
