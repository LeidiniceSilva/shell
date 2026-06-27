#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 8
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Merge_files
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

# Path
base_path="/leonardo_work/ICT26_ESP/CORDEX-CMIP6/DD/CSAM-3/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1"

# Info
base="CSAM-3_ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1"
version="v20260622"

# Clean outputs
#echo "Removing old $version and tmp files..."
#find "$base_path" -type d -name "$version" -exec rm -rf {} \;
#find "$base_path" -type f -name "*_tmp_*.nc" -delete
#echo "Cleanup done"

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
    echo "Files: $files"

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
        # rm -f $files

      else
        rm -f $tmp
      fi

    fi

    cd ..
  done
done
