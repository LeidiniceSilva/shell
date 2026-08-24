#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Merge_files
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Aug 24, 2026'
#__description__ = 'Merge hourly MERGIR files by month'

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

base_dir="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/GPM/globe/GPM_MERGIR"
out_dir="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/GPM/globe/MERGE/MERGIR"

mkdir -p "$out_dir"

for year in $(seq 2000 2000); do

  dir="${base_dir}/${year}"
  cd "$dir" || continue

  for mon in $(seq -w 02 12); do

    tmp="${out_dir}/tmp_${year}${mon}.nc"
    output="${out_dir}/merg_${year}${mon}_4km-pixel_1hr.nc"

    echo "Year:   $year"
    echo "Month:  $mon"
    echo "Output: $output"

    # Skip if monthly file already exists
    if [ -f "$output" ]; then
      echo "File already exists: $output"
      continue
    fi

    # Check number of days in the month
    days=$(python3 -c "import calendar; print(calendar.monthrange(${year}, ${mon#0})[1])")

    # Expected number of hourly files (1 file per hour)
    expected=$((days * 24))

    # Number of hourly files available
    actual=$(ls merg_${year}${mon}*_4km-pixel.nc4 2>/dev/null | wc -l)

    echo "Expected files: $expected"
    echo "Found files:    $actual"

    # Check if all files are available
    if [ "$actual" -ne "$expected" ]; then
      echo "WARNING: Missing files for ${year}-${mon}"
      echo "Skipping ${year}-${mon}"
      continue
    fi

    # Merge hourly files and calculate hourly mean across the 2 internal timesteps
    echo "Merging ${year}-${mon}..."

    CDO mergetime merg_${year}${mon}*_4km-pixel.nc4 "$tmp"
    CDO timselmean,2 "$tmp" "$output"
    rm -f "$tmp"

    if [ $? -eq 0 ]; then
      echo "Successfully created: $output"
    else
      echo "ERROR: CDO failed for ${year}-${mon}"
      rm -f "$output" "$tmp"
    fi

  done
done

echo "Done"
