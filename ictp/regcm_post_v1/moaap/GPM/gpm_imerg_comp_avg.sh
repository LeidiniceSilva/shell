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
#__description__ = 'Merge hourly IMERG files by month'

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

base_dir="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/GPM/globe/GPM_IMERG"
out_dir="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/GPM/globe/MERGE/IMERG"
mkdir -p "$out_dir"

for year in $(seq 2005 2005); do

  dir="${base_dir}/${year}"
  cd "$dir" || continue
  echo "$dir"

  for mon in $(seq -w 01 12); do

    tmp="${out_dir}/tmp_${year}${mon}.nc"
    output="${out_dir}/imerg_${year}${mon}_1hr_v07b.nc"

    echo "Year:   $year"
    echo "Month:  $mon"
    echo "Output: $output"

    CDO mergetime 3B-HHR.MS.MRG.3IMERG.${year}${mon}*.V07B.nc "$tmp"
    CDO timselsum,2 "$tmp" "$output"
    rm -f "$tmp"

  done
done

echo "Done"
