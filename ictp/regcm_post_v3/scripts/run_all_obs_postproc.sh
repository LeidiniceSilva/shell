#!/bin/bash

{

source /marconi/home/userexternal/ggiulian/STACK22/env2022
set -eo pipefail

if [ $# -ne 1 ]
then
   echo "Please provide period"
   echo "Example: $0 2000-2001" 
   exit 1
fi

ys=$1 
rdir=/marconi/home/userexternal/mdasilva/user/mdasilva/EUR-11/obs

# Processing the mean
list1="cpc cru eobs era5_srf gpcc mswep"

# Processing the pdf
list2="cpc cru eobs gpcc"

hdir=/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v3/scripts_obs

for l in $list1; do
  echo "===== processing mean: $l ====="
  bash ${hdir}/prepare_${l}.sh $ys $rdir
done

for l in $list2; do
  echo "===== processing pdf: $l ====="
  bash ${hdir}/prepare-pdf_${l}.sh $ys $rdir
done

}
