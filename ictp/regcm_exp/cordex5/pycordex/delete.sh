#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 12
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Merge_files
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

# Path
#base_path="/leonardo_work/ICT26_ESP/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1"
base_path="/leonardo_work/ICT26_ESP/CORDEX-CMIP6/DD/CSAM-3/ICTP/EC-Earth3-Veg/historical/r1i1p1f1/RegCM5-0/v1-r1"

# Info
#base="CSAM-3_ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1"
base="CSAM-3_EC-Earth3-Veg_historical_r1i1p1f1_ICTP_RegCM5-0_v1-r1"
version="v20260622"
year=$1

for f in 1hr 3hr 6hr day
do

  cd "$base_path/$f" || continue

  for var in *
  do

    [ -d "$var" ] || continue
    cd "$var" || continue

    files=$(ls ${var}_${base}_${f}_${year}* 2>/dev/null)

    if [ ! -z "$files" ]; then

      echo "Files to be removed in $var:"
      echo "$files"
      #rm -f $files
      #rm *"tmp"*

    fi

    cd ..
  done
done
