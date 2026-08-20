#!/bin/bash

#################
##### input #####
#################

# Base directory
base=/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5

# pycordexer output directory
wdir=${base}/pycordexer/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5-0/v1-r1

# Frequencies
frequencies=("1hr" "3hr" "6hr" "day")

########################
##### end of input #####
########################

set -eo pipefail

echo
echo "=========================================================="
echo "CHECKING PYCORDEXER OUTPUT"
echo "=========================================================="
echo "Output directory:"
echo "${wdir}"
echo

total_ok=0
total_missing=0

for freq in "${frequencies[@]}"; do

    freq_dir="${wdir}/${freq}"

    echo
    echo "=========================================================="
    echo "FREQUENCY: ${freq}"
    echo "=========================================================="

    # Check frequency directory
    if [[ ! -d "${freq_dir}" ]]; then
        echo "ERROR: directory does not exist:"
        echo "${freq_dir}"
        continue
    fi

    # Loop over variable directories
    for var_dir in "${freq_dir}"/*; do

        # Only directories
        [[ -d "${var_dir}" ]] || continue

        var=$(basename "${var_dir}")

        # Find NetCDF files
        files=( "${var_dir}"/*.nc )

        # No files
        if [[ ! -e "${files[0]}" ]]; then
            echo "MISSING   ${var}"
            total_missing=$((total_missing + 1))
            continue
        fi

        # Number of files
        nfiles=${#files[@]}

        echo "OK        ${var}    ${nfiles} file(s)"

        total_ok=$((total_ok + 1))

    done

done

echo
echo "=========================================================="
echo "SUMMARY"
echo "=========================================================="
echo "Variables with files : ${total_ok}"
echo "Variables missing    : ${total_missing}"
echo "=========================================================="
