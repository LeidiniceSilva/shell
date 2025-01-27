#!/bin/bash

{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

if [ $# -ne 1 ]
then
   echo "Please provide period"
   echo "Example: $0 2000-2001" 
   exit 1
fi

ys=$1 
rdir=/leonardo/home/userexternal/mdasilva/leonardo_work/OBS/postproc
hdir=/leonardo/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_post_v3/scripts_obs

# Processing the average
list1="cpc cru eobs era5 gpcp mswep"

# Processing the pdf
list2="cpc eobs era5 gpcp mswep"

for l in $list1; do
  echo "===== processing mean: $l ====="
  bash ${hdir}/prepare_${l}.sh $ys $rdir
done

for l in $list2; do
  echo "===== processing pdf: $l ====="
  bash ${hdir}/prepare-pdf_${l}.sh $ys $rdir
done

}
