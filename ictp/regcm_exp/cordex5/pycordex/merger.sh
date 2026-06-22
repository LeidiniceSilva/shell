#!/bin/bash

#SBATCH --account            ICT26_ESP
#SBATCH --job-name           MERGE
#SBATCH --mail-type          FAIL
#SBATCH --mail-user          mda_silv@ictp.it
#SBATCH --nodes              1
#SBATCH --ntasks-per-node    1
#SBATCH --partition          dcgp_usr_prod
#SBATCH --time               12:00:00

base_path="/leonardo_work/ICT26_ESP/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1"

# Info
base="CSAM-3_ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1"
version="v20260622"

year=$1
next_year=$((year + 1))

for f in 1hr 3hr 6hr day
do
  cd "$base_path/$f" || continue

  for var in *
  do
    [ -d "$var" ] || continue
    cd "$var" || continue

    mkdir -p "$version"

    # Match files 
    files=$(ls ${var}_${base}_${f}_${year}* 2>/dev/null)

    if [ ! -z "$files" ]; then

      tmp="${var}_tmp_${$}.nc"
      ncrcat -h $files $tmp

      if [ $? -eq 0 ]; then

        # Output filename 
        if [ "$f" = "day" ]; then
          out="${var}_${base}_${f}_${year}0101-${year}1231.nc"
        else
          out="${var}_${base}_${f}_${year}01010100-${next_year}01010000.nc"
        fi

        # Move the merged 
        mv $tmp "$version/$out"

        # Delete the original files 
        rm -f $files

      else
        rm -f $tmp
      fi

    fi

    cd ..
  done
done
